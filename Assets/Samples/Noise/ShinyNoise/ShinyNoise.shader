/*
参考リンク
http://glslsandbox.com/e#67999.0
*/
Shader "Unlit/ShinyNoise"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _BlendRatio ("Blend Ratio", Range(0.0, 1.0)) = 0.1
        _Attitude ("Attitude", Range(-1.0, 1.0)) = 0.0
        _Detail ("Detail", Range(0.0001, 0.1)) = 0.005
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
            float _BlendRatio;
            float _Attitude;
            float _Detail;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f IN) : SV_Target
            {
                // スクリーンの解像度でどのピクセルを描画しようとしているのか
                float2 fragCoord = IN.uv * _ScreenParams; // (0.0~1.0) x (Screen.width, Screen.height)

                // (fragCoord.xy - _ScreenParams * 0.5) / max(_ScreenParams.x, _ScreenParams.y) -> 画面の長い方に合わせて-0.5~0.5に変形してる
                // 縦長の場合 (x / y, 0~1.0)になってさらに8.0を掛け合わせることでUV座標を拡張してる
                float2 uv = (fragCoord.xy - _ScreenParams * 0.5) / max(_ScreenParams.x, _ScreenParams.y);
                uv *= 8.0;

                float e = 0.0;
                for (float i = 1.0; i <= 13.0; i += 1.0) 
                {
                    // e += abs(cos(uv.y) + sin(uv.x));
                    e += _Detail / abs(cos(_Time.y + i * uv.y) + sin(_Time.y + i * uv.x));
                    // e += _Detail / abs(cos(_Time.y + uv.y) + sin(_Time.y + uv.x));
                    // e += _Detail / abs(cos(_Attitude + i * uv.y) + sin(_Attitude + i * uv.x));
                }
                return fixed4(e, e, 0.0, _BlendRatio);
            }
            ENDCG
        }
    }
}
