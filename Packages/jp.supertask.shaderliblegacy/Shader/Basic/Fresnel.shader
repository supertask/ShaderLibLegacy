Shader "Basic/Fresnel"
{
	Properties
	{
		_MainTex ("Base (RGB) Trans (A)", 2D) = "white" {}
		_Color ("Color", Color) = (1,1,1,1)
		_FresnelColor ("Fresnel Color", Color) = (1,1,1,1)
		_FresnelBias ("Fresnel Bias", Float) = 0
		_FresnelScale ("Fresnel Scale", Float) = 1
		_FresnelPower ("Fresnel Power", Float) = 1
	}

	SubShader
	{
		Tags
		{
			"Queue"="Geometry"
			"IgnoreProjector"="True"
			"RenderType"="Opaque"
		}

		//Cull Back
		//Cull Front
		Cull Off

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 2.0

			#include "UnityCG.cginc"
			#include "UnityLightingCommon.cginc"
			#include "Packages/jp.supertask.shadersLib/Shader/Lib/SpecularAndDiffuse.hlsl"

			struct appdata_t
			{
				float4 pos : POSITION;
				float2 uv : TEXCOORD0;
				half3 normal : NORMAL;
				float3 color : COLOR;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				half2 uv : TEXCOORD0;
				float fresnel : TEXCOORD1;
				float rim : TEXCOORD2;
				float3 diffuseReflection : TEXCOORD3;
				float3 specularReflection : TEXCOORD4;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			fixed4 _Color;
			fixed4 _FresnelColor;
			fixed _FresnelBias;
			fixed _FresnelScale;
			fixed _FresnelPower;
			
			v2f vert(appdata_t v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.pos);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				float3 posWS = mul(unity_ObjectToWorld, v.pos);

				float3 viewDir = normalize(ObjSpaceViewDir(v.pos));
				o.fresnel = _FresnelBias + _FresnelScale * pow(1 + dot(viewDir, v.normal), _FresnelPower);

				SpecularAndDiffuse_float(
					viewDir, v.normal, posWS, v.color,
					true, _WorldSpaceLightPos0, _LightColor0,
					float4(1,1, 1, 1), 1.0,
					o.diffuseReflection, o.specularReflection);
				return o;
			}

			fixed4 frag(v2f IN) : SV_Target
			{
				fixed4 col = float4(IN.diffuseReflection + IN.specularReflection, 1)
					* tex2D(_MainTex, IN.uv) * _Color;
                return lerp(col, _FresnelColor, (1 - IN.fresnel));
			}
			ENDCG
		}
	}
}