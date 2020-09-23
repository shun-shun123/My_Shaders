// http://www.shaderslab.com/demo-71---truchet---arabesque.html
Shader "Custom/Noise/Arabesque" {
    Properties {
        _Factor1 ("Factor 1", float) = 1.0
        _Factor2 ("Factor 2", float) = 1.0
        _Factor3 ("Factor 3", float) = 1.0

        _GridSize ("GridSize", float) = 1.0
        _Border ("Border", range(0.0, 0.5)) = 0.1
    }

    SubShader {
        Tags { "RenderType" = "Opaque" }

        Pass {
            CGPROGRAM
            #pragma vertex vert_img
            #pragma fragment frag

            #include "UnityCG.cginc"

            float _Factor1;
            float _Factor2;
            float _Factor3;

            float _GridSize;

            float2 truchetPattern(float2 uv, float index) {
                // indexの値は-0.99... ~ 0.999で来るので、-0.5すると -1.5 ~ 0.5の範囲に変化し、*2.0すると-3.0~1.0の値になり、fracをすると-0.0~1.0に変わる　
                index = frac((index - 0.5) * 2.0);

                if (index > 0.75) {
                    return float2(1.0, 1.0) - uv;
                }

                if (index > 0.5) {
                    return uv;
                }

                if (index > 0.25) {
                    // (左下): 0, 0 => 0.0, 1.0, (右上): 1.0, 0.0
                    return 1.0 - float2(1.0 - uv.x, uv.y);
                }

                return uv;
            }

            float noise(half2 uv) {
                // uvと(_Factor1, _Factor2)の内積を取る
                // dotの内部実装から考えると、内積は距離の比較などにも使える。つまり、vec2から適当なfloat（距離のようなもの）を計算したいときにも使える
                // float innerProduct = uv.x * _Factor1 + uv.y * _Factor2;
                float innerProduct = dot(uv, float2(_Factor1, _Factor2));
                float sinResult = sin(innerProduct);    // -1.0 ~ 1.0 に変換
                return frac(sinResult * _Factor3);  // -1.0 ~ 1.0 => -_Factor3 ~ _Factor3 => -0.xx ~ 0.xx
            }

            fixed Circle(float2 uv, float2 center, float radius, float border) {
                // step(y, x): y<=xなら1, y>xなら0を出力するステップ関数
                // centerからuvまでの距離がradius + borderの範囲内に入っていれば1を、それ以外なら0を返すようになっている
                return step(length(uv - center), radius + border/2) - step(length(uv - center), radius - border/2);
            }

            float _Border;

            fixed4 frag(v2f_img i) : SV_Target {
                // GridSizeで分けることで1x1のUVが_GridSizex_GridSize個の小さな四角形の集合に変わる
                i.uv *= _GridSize;

                // 小数値の整数部分を返す。一つ一つの四角形のインデックスになる
                float2 intVal = floor(i.uv);
                // 小数値の少数部分を返す。一つ一つの四角形のUVになる
                float2 fracVal = frac(i.uv);
                float2 tile = truchetPattern(fracVal, noise(intVal));
                // return fixed4(tile.x, tile.y, 0, 1.0);

                // return fixed4(Circle(tile, float2(0.5, 1.0), 0.25, _Border), 0.0, 0.0, 1.0);
                fixed circleVal = Circle(i.uv  /_GridSize, float2(0.5, 0.5), 0.4, _Border);

                fixed val = Circle(tile, float2(0.5, 1.0), 0.25, _Border)
                + Circle(tile, float2(0.0, 0.0), 0.25, _Border)
                + Circle(tile, float2(0.0, 0.5), 0.25, _Border)
                + Circle(tile, float2(0.0, 1.0), 0.50, _Border)
                + Circle(tile, float2(1.0, 0.0), 0.50, _Border)
                + Circle(tile, float2(1.0, 0.0), 0.25, _Border)
                + Circle(tile, float2(1.0, 0.625), 0.125, _Border);

                return fixed4(val, val, val, 1);
            }
            ENDCG
        }
    }
}