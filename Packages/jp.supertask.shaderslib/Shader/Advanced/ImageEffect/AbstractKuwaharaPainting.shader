// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Advanced/ImageEffect/AbstractKuwaharaPainting"
{
    Properties
    {
        _MainTex("Texture", 2D) = "white" {}

        _KuwaharaRadius ("Kuwahara Radius", Range(0, 10)) = 10
        _SobelLineColor ("Sobel Line Color", Color) = (1,1,1,1)
        _SobelDeltaX ("Delta X", Float) = 0.01
		_SobelDeltaY ("Delta Y", Float) = 0.01
    }
    SubShader
    {
        //Blend SrcAlpha OneMinusSrcAlpha
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 5.0

            #pragma multi_compile _ DEBUG_COLORFUL_FRACTAL

            #include "UnityCG.cginc"
            
            #include "Packages/jp.supertask.shadersLib/Shader/Lib/PhotoshopMath.hlsl"
            #include "Packages/jp.supertask.shadersLib/Shader/Basic/ImageEffect/SobelFilter.hlsl"
            #include "Packages/jp.supertask.shadersLib/Shader/Lib/KeijiroNoise/SimplexNoise2D.hlsl"
            #include "Packages/jp.supertask.shadersLib/Shader/Lib/KeijiroNoise/ClassicNoise2D.hlsl"
            #include "Packages/jp.supertask.shadersLib/Shader/Lib/fbm.hlsl"


            /*
			struct appdata_t
			{
				float4 vertex : POSITION;
				float2 texcoord : TEXCOORD0;
				half3 normal : NORMAL;
			};
            */
 
            struct v2f {
                float4 pos : SV_POSITION;
                half2 uv : TEXCOORD0;
            };
 
            sampler2D _MainTex;
            float4 _MainTex_ST;

            sampler2D _ColorfulFractalTex;
            float4 _ColorfulFractalTex_ST;
            
            sampler2D _CameraDepthTexture;
            
            float4 _SobelLineColor;
            float _SobelDeltaX;
            float _SobelDeltaY;

            v2f vert(appdata_base v) {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);

                return o;
            }
 
            int _KuwaharaRadius;
            float4 _MainTex_TexelSize;
 
            float4 frag (v2f i) : SV_Target
            {
                half2 uv = i.uv;
#ifdef DEBUG_COLORFUL_FRACTAL
                return tex2Dlod(_ColorfulFractalTex, float4(uv, 0, 0));
#endif

                float3 mean[4] = {
                    {0, 0, 0},
                    {0, 0, 0},
                    {0, 0, 0},
                    {0, 0, 0}
                };
 
                float3 sigma[4] = {
                    {0, 0, 0},
                    {0, 0, 0},
                    {0, 0, 0},
                    {0, 0, 0}
                };
 
                float2 start[4] = {{-_KuwaharaRadius, -_KuwaharaRadius}, {-_KuwaharaRadius, 0}, {0, -_KuwaharaRadius}, {0, 0}};
 
                float2 pos;
                float3 col;
                for (int k = 0; k < 4; k++) {
                    for(int i = 0; i <= _KuwaharaRadius; i++) {
                        for(int j = 0; j <= _KuwaharaRadius; j++) {
                            pos = float2(i, j) + start[k];
                            col = tex2Dlod(_MainTex, float4(uv + float2(pos.x * _MainTex_TexelSize.x, pos.y * _MainTex_TexelSize.y), 0., 0.)).rgb;
                            mean[k] += col;
                            sigma[k] += col * col;
                        }
                    }
                }
 
                float sigma2;
 
                float n = pow(_KuwaharaRadius + 1, 2);
                float4 color = tex2D(_MainTex, uv);
                float min = 1;
 
                for (int l = 0; l < 4; l++) {
                    mean[l] /= n;
                    sigma[l] = abs(sigma[l] / n - mean[l] * mean[l]);
                    sigma2 = sigma[l].r + sigma[l].g + sigma[l].b;
 
                    if (sigma2 < min) {
                        min = sigma2;
                        color.rgb = mean[l].rgb;
                    }
                }
                float4 lines = _SobelLineColor * sobelFilter(_MainTex, uv, float2(_SobelDeltaX, _SobelDeltaY));
                lines *= fbm(uv * 10);
                //lines *= SimplexNoise(uv*0.1);
                //return ;
                //return PeriodicNoise(uv*20, float3(10, 10,0));
                
                bool objExists = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv) > 0;
                float4 colorFractal = tex2Dlod(_ColorfulFractalTex, float4(uv, 0, 0));
                color.rgb = objExists ? BlendSoftLight(color.rgb, colorFractal) : color.rgb;
                color.rgb = BlendHardLight(color.rgb, lines);
                return color;
            }
            ENDCG
        }
    }
}