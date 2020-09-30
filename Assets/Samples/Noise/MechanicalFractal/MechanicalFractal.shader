/* 
参考リンク
http://glslsandbox.com/e#67883.0
*/
Shader "Unlit/MechanicalFractal"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _MouseX ("Mouse X", float) = 0.0
        _MouseY ("Mouse Y", float) = 0.0
        _BlendRatio ("Blend Ratio", Range(0.0, 1.0)) = 1.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass 
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f 
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v) 
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f IN) : SV_TARGET
            {
                return tex2D(_MainTex, IN.uv);
            }
            ENDCG
        }

        Pass
        {
            Blend SrcAlpha One
            // Blend OneMinusDstColor One

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Assets/MyCginc/mechanicalFractral.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _MouseX;
            float _MouseY;
            float _BlendRatio;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            // voronoi distance noise, based on iq's articles
            float voronoi(float2 x)
            {
                float2 p = floor(x);
                float2 f = frac(x);
                
                float2 res = float2(8.0, 8.0);
                for(int j = -1; j <= 1; j ++)
                {
                    for(int i = -1; i <= 1; i ++)
                    {
                        float2 b = float2(i, j);
                        float2 r = float2(b) - f + rand2d(p + b);
                        
                        // chebyshev distance, one of many ways to do this
                        float d = max(abs(r.x), abs(r.y));
                        
                        if(d < res.x)
                        {
                            res.y = res.x;
                            res.x = d;
                        }
                        else if(d < res.y)
                        {
                            res.y = d;
                        }
                    }
                }
                return res.y - res.x;
            }

            fixed4 mainImage(fixed4 fragColor, fixed2 fragCoord) 
            {
                float time = _Time.y;
                float flicker = noise1d(time * 2.0) * 0.8 + 0.4;

                fixed2 uv = fragCoord.xy / _ScreenParams.xy;
                uv = (uv - 0.5) * 2.0;
                fixed2 suv = uv;
                uv.x *= _ScreenParams.x / _ScreenParams.y;
                
                
                float v = 0.0;
                
                // that looks highly interesting:
                //v = 1.0 - length(uv) * 1.3;
                
                
                // a bit of camera movement
                uv *= 0.6 + sin(time * 0.1) * 0.4;
                uv = rotateVec2(uv, sin(time * 0.1) * 1.0);
                uv += time * 0.1;
                
                
                // add some noise octaves
                float a = 0.6, f = 1.0;
                
                for(int i = 0; i < 3; i ++) // 4 octaves also look nice, its getting a bit slow though
                {	
                    float v1 = voronoi(uv * f + 5.0);
                    float v2 = 0.0;
                    
                    // make the moving electrons-effect for higher octaves
                    if(i > 0)
                    {
                        // of course everything based on voronoi
                        v2 = voronoi(uv * f * 0.5 + 50.0 + time);
                        
                        float va = 0.0, vb = 0.0;
                        va = 1.0 - smoothstep(0.0, 0.1, v1);
                        vb = 1.0 - smoothstep(0.0, 0.08, v2);
                        v += a * pow(va * (0.5 + vb), 2.0);
                    }
                    
                    // make sharp edges
                    v1 = 1.0 - smoothstep(0.0, 0.3, v1);
                    
                    // noise is used as intensity map
                    v2 = a * (noise1d(v1 * 5.5 + 0.1));
                    
                    // octave 0's intensity changes a bit
                    if(i == 0)
                    v += v2 * flicker;
                    else
                    v += v2;
                    
                    f *= 3.0;
                    a *= 0.7;
                }

                // slight vignetting
                v *= exp(-0.6 * length(suv)) * 1.2;
                
                // use texture channel0 for color? why not.
                fixed3 cexp = fixed3(1.0, 1.0, 1.0) * 3.0 + fixed3(1.0, 1.0, 1.0);//vec3(1.0, 2.0, 4.0);
                cexp *= 1.4;
                
                // old blueish color set
                cexp = fixed3(113.0, 1.3, 1111.0);
                
                fixed3 col = fixed3(pow(v, cexp.x), pow(v, cexp.y), pow(v, cexp.z)) * 2.0;
                
                fragColor = fixed4(col, _BlendRatio);
                return fragColor;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed timer = _Time.y;
                float2 position = i.uv + float2(_MouseX, _MouseY) / 4.0;

                float color = 0.0;
                color += sin(position.x * cos(timer / 15.0) * 80.0) + cos(position.y * cos(timer / 15.0) * 10.0);
                color += sin(position.y * sin(timer / 10.0) * 40.0) + cos(position.x * sin(timer / 25.0) * 40.0);
                color += sin(position.x * sin(timer / 5.0) * 10.0) + sin(position.y * sin(timer / 35.0) * 80.0);
                color *= sin(timer / 10.0) * 0.5;

                fixed4 outColor = fixed4(color, color * 0.5, sin(color + timer / 3.0) * 0.75, 1.0);
                float2 fragCoord = i.uv * _ScreenParams.xy;
                return mainImage(outColor, fragCoord);
            }
            ENDCG
        }
    }
}
