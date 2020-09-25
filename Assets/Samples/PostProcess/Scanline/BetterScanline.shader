Shader "Unlit/BetterScanline"
{
    Properties
    {
        _MainTex ("Main Texture", 2D) = "white" {}
        _NoiseX ("Noise X", Range(0, 1)) = 0
        _Offset ("Offset", vector) = (0, 0, 0, 0)
        _RGBNoise ("RGB Noise", Range(0, 1)) = 0
        _SinNoiseWidth ("Sine Noise Width", float) = 1
        _SinNoiseScale ("Sine Noise Scale", float) = 1
        _SinNoiseOffset ("Sine Noise Scale", float) = 1
        _ScanLineTail ("Tail", float) = 0.5
        _ScanLineSpeed ("Tail Speed", float) = 100
    }
    SubShader
    {
        Cull Off ZWrite Off ZTest Always

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

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            // 2次元ベクトルからランダムなfloatを生成して返す
            float rand(float2 co) 
            {
                return frac(sin(dot(co.xy, float2(12.9898, 78.233))) * 43758.5453);
                // return frac(sin(co.xy) * 43758.5453);
            }

            // modを計算する
            // modとは5mod2=1といった、除算した余りのこと
            float2 mod(float2 a, float2 b) 
            {
                // floor(a / b)でa/bの整数値部分だけを取り出してbを掛け合わせる
                // それをaから引くことで剰余が計算できる
                return a - floor(a / b) * b;
            }

            sampler2D _MainTex;
            float _NoiseX;
            float _Offset;
            float _RGBNoise;
            float _SinNoiseWidth;
            float _SinNoiseScale;
            float _SinNoiseOffset;
            float _ScanLineTail;
            float _ScanLineSpeed;

            fixed4 frag (v2f i) : SV_Target
            {
                float2 inUV = i.uv;
                // uv-0.5することでUV座標の中央が画面の中央となる
                float2 uv = i.uv - 0.5;

                // UV座標を計算し、画面を歪ませる
                float vignet = length(uv);
                // これで画面中央から徐々に赤くなっていくグラデーションが作成できる
                // return fixed4(vignet, 0, 0, 1.0);

                uv /= 1 - vignet * 0.2;
                float2 texUV = uv + 0.5;

                // 画面外なら描画しない
                // uv - 0.5してるからさらに-0.5しても0以上なら画面外となる
                if (max(abs(uv.y) - 0.5, abs(uv.x) - 0.5) > 0)
                {
                    return float4(0, 0, 0, 1);
                }

                // 色を計算
                float3 col;
                texUV.x += sin(texUV.y * _SinNoiseWidth + _SinNoiseOffset) * _SinNoiseScale;
                texUV += _Offset;
                texUV.x += (rand(floor(texUV.y * 500) + _Time.y) - 0.5) * _NoiseX;

                // 色を取得、RGBを少しずつずらす
                col.r = tex2D(_MainTex, texUV).r;
                col.g = tex2D(_MainTex, texUV - float2(0.002, 0)).g;
                col.b = tex2D(_MainTex, texUV - float2(0.004, 0)).b;

                // RGBノイズ
                if (rand((rand(floor(texUV.y * 500) + _Time.y) - 0.5) + _Time.y) < _RGBNoise)
                {
                    col.r = rand(uv + float2(123 + _Time.y, 0));
                    col.g = rand(uv + float2(123 + _Time.y, 1));
                    col.b = rand(uv + float2(123 + _Time.y, 2));
                }

                // ピクセル毎に描画するRGBを決める
                // fmod(a, b): aをbで除算したときに得られる正の剰余が得られます.
                float floorX = fmod(inUV.x * _ScreenParams.x / 3, 1);   // ScreenParams.x: 現在のレンダリングターゲットのピクセル幅
                col.r *= floorX > 0.33333;
                col.g *= floorX < 0.33333 || floorX > 0.6666;
                col.b *= floorX < 0.6666;

                // スキャンラインを描画
                float scanLineColor = sin(_Time.y * 10 + uv.y * 500) / 2 + 0.5;
                col *= 0.5 + clamp(scanLineColor + 0.5, 0, 1) * 0.5;

                // スキャンラインの残像を描画
                float tail = clamp((frac(uv.y + _Time.y * _ScanLineSpeed) - 1 + _ScanLineTail) / min(_ScanLineTail, 1), 0, 1);
                col *= tail;

                // 画面端を暗くする
                col *= 1 - vignet * 1.3;

                return fixed4(col, 1);
            }
            ENDCG
        }
    }
}
