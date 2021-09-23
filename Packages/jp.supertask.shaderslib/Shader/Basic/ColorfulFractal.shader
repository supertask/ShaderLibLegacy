// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Basic/Noise/ColorfulFractal" 
{
	Properties 
	{
		_MainTex ("Main Tex", 2D) = "white" {}
		_FractalTiling ("Fractal Tiling", Vector) = (5, 5, 60, 0)
		_OffsetX ("Offsets X", Vector) = (3, 13, 29, 43)
		_OffsetY ("Offsets Y", Vector) = (7, 19, 37, 53)
		_Gain ("Gain", Vector) = (2, 0.5, 0, 0)
	}
	SubShader 
	{
		ZTest Always 
		ZWrite Off 
		Cull Off 
		Fog { Mode Off }
		
		Pass 
		{
			HLSLPROGRAM
			#pragma target 5.0
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
			#include "Packages/jp.supertask.shadersLib/Shader/Lib/KeijiroNoise/SimplexNoise2D.hlsl"
			//#include "Assets/Packages/ShaderLib/Shader/SimplexNoise.hlsl"
			//#include "Assets/Packages/ShaderLib/Shader/Noise.hlsl"
			#define NOISE(uv) SimplexNoise(uv)
			//#define NOISE(uv) curlNoise(uv)
			//#define NOISE(uv) cnoise(uv)
			//#define NOISE(uv) pnoise(uv, float3(0,0,0))
			
			sampler2D _MainTex;
			float4 _MainTex_TexelSize;
			float4 _MainTex_ST;
			float4 _FractalTiling;
			float _TimeShift;
			float4 _OffsetX, _OffsetY;
			float4 _Gain;
			float4x4 _ColorMatrix;

			struct vsin 
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct vs2ps 
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};
			
			vs2ps vert(vsin IN) 
			{
				float2 uv = TRANSFORM_TEX(IN.uv, _MainTex);
				uv.x *= _ScreenParams.x / _ScreenParams.y;
				
				vs2ps OUT;
				OUT.vertex = UnityObjectToClipPos(IN.vertex);
				OUT.uv = uv;
				return OUT;
			}
			
			float4 frag(vs2ps IN) : COLOR 
			{
				//float2 uvFractal = IN.uv * _FractalTiling.xy;
				float4 y = 0;
				for (int i = 0; i < 4; i++) 
				{
					float3 x = half3(IN.uv + float2(_OffsetX[i], _OffsetY[i]), _TimeShift) * _FractalTiling.xyz;
					y[i] = 0.553 * (NOISE(x) + 0.5 * NOISE(2 * x) + 0.25 * NOISE(4 * x) + 0.125 * NOISE(8 * x));
				}
				return mul(_ColorMatrix, _Gain.x * y + _Gain.y);
			}
			ENDHLSL
		} // end Pass
	} // end SubShader
	FallBack Off
} // end shader

