/*
参考リンク
http://glslsandbox.com/e#67934.0
*/
Shader "Unlit/ColorfulVoronoi"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _BlendAlpha ("Blend Alpha", Range(0.0, 1.0)) = 1.0
        _Strength ("Strength", vector) = (1.0, 1.0, 1.0, 1.0)
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
            float _BlendAlpha;
            fixed4 _Strength;

            // 0.0~0.999...を返す
            fixed2 hash(fixed2 p) 
            {
                float2x2 m = float2x2(
                13.85, 47.77,
                99.41, 88.48);
                return frac(sin(mul(m, p)) * 46738.29);
            }

            float voronoi(fixed2 p) 
            {
                fixed2 g = floor(p);
                fixed2 f = frac(p);

                float distanceToClosestFeaturePoint = 1.0;
                // (-1, -1), (0, -1), (1, -1)
                // (-1,  0), (0,  0), (1,  0)
                // (-1,  1), (0,  1), (1,  1)の9点を作成するためのループ
                for (int y = -1; y <= 1; y++)
                {
                    for (int x = -1; x <= 1; x++) 
                    {
                        fixed2 latticePoint = fixed2(x, y);
                        // float currentDistance = distance(latticePoint + hash(g + latticePoint), f);
                        float currentDistance = distance(latticePoint, f);
                        distanceToClosestFeaturePoint = min(distanceToClosestFeaturePoint, currentDistance);
                    }
                }
                return distanceToClosestFeaturePoint;
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // fixed time = 0;
                fixed time = _Time.y;
                // uvを-1.0~1.0に変換
                fixed2 uv = i.uv * 2.0 - 1.0;
                // uv.x *= _ScreenParams.x / _ScreenParams.y;

                // 9点から最も近い点を探す
                float offset = voronoi(uv * 10.0 + fixed2(time, time));
                float t = 1.0 / abs(((uv.x + sin(uv.y + time)) + offset) * 30.0);

                float r = voronoi(uv) * 10.0;
                // fixed3 finalColor = fixed3(10.0 * uv.y, 2.0, 1.0 * r) * t;
                fixed3 finalColor = fixed3(r * _Strength.r, r * _Strength.g, r * _Strength.b) * t;
                return fixed4(finalColor, _BlendAlpha);
            }
            ENDCG
        }
    }
}
