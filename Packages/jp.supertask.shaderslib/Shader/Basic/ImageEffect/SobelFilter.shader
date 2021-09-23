Shader "Basic/ImageEffect/SobelFilter" {

	Properties {
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_DeltaX ("Delta X", Float) = 0.01
		_DeltaY ("Delta Y", Float) = 0.01
	}
	
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		CGINCLUDE
		
		#include "UnityCG.cginc"
		#include "./SobelFilter.hlsl"
		sampler2D _MainTex;
		float _DeltaX;
		float _DeltaY;
		
		float4 frag (v2f_img IN) : COLOR {
			float s = sobelFilter(_MainTex, IN.uv, float2(_DeltaX, _DeltaY));
			return float4(s, s, s, 1);
		}
		
		ENDCG
		
		Pass {
			CGPROGRAM
			#pragma vertex vert_img
			#pragma fragment frag
			ENDCG
		}
		
	} 
	FallBack "Diffuse"
}