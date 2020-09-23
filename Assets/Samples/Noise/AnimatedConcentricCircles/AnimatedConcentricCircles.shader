// http://www.shaderslab.com/demo-01---concentric-circles.html

Shader "Custom/Noise/Aniamted Concentric Circles" {
    Properties {
        _OrigineX ("PosX Origine", Range(0, 1)) = 0.5
        _OrigineY ("PosY Origine", Range(0, 1)) = 0.5
        _Speed ("Speed", Range(-100, 100)) = 60.0
        _CircleNbr ("Circle quantity", Range(10, 1000)) = 60.0
    }

    SubShader {
        Pass {
            CGPROGRAM
            // #pragma vertex name: 関数nameを頂点シェーダとしてコンパイル
            #pragma vertex vert

            // #pragma fragment name: 関数nameをフラグメントシェーダとしてコンパイル
            #pragma fragment frag

            // 一般的に使用されるヘルパー関数を定義したライブラリを追加
            #include "UnityCG.cginc"

            // #pragm target name: コンパイルするシェーダーターゲットの指定
            // https://docs.unity3d.com/ja/2018.4/Manual/SL-ShaderCompileTargets.html
            #pragma target 3.0

            float _OrigineX;
            float _OrigineY;
            float _Speed;
            float _CircleNbr;

            struct vertexInput {
                float4 vertex : POSITION;
                float4 texcoord0 : TEXCOORD0;
            };

            struct fragmentInput {
                float4 position : SV_POSITION;
                float4 texcoord0 : TEXCOORD0;
            };

            // 頂点シェーダ
            fragmentInput vert(vertexInput i) {
                fragmentInput o;
                // オブジェクト空間→カメラのクリップ空間への変換
                // o.position = UnityObjectToClipPos(i.vertex); // これと同じ意味を持つ
                o.position = UnityObjectToClipPos(i.vertex);

                // TEXCOORD0は一番目のUV座標
                o.texcoord0 = i.texcoord0;

                // フラグメントシェーダに出力する
                return o;
            }

            // フラグメントシェーダ
            fixed4 frag(fragmentInput i) : SV_Target {
                fixed4 color;
                float distanceToCenter;
                float time = _Time.x * _Speed;

                // i.texcoord0は(0~1.0)のUV座標
                float xdist = _OrigineX - i.texcoord0.x;
                float ydist = _OrigineY - i.texcoord0.y;


                // 0 ~ 0.5 => 0 ~ _CircleNbrに拡張してる。sinに渡すときに触れ幅が大きいほど縁を描ける
                // distanceToCenter = (xdist * xdist + ydist * ydist); // 0 ~ 0.5
                distanceToCenter = (xdist * xdist + ydist * ydist) * _CircleNbr;

                color = sin(distanceToCenter + time);
                // color = sin((i.texcoord0.x + time) * (i.texcoord0.y + time));
                return color;
            }
            ENDCG
        }
    }
}