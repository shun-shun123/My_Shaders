Shader "Unlit/Billboard"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _PixelNumberX ("Pixel number along X", float) = 500
        _PixelNumberY ("Pixel number along Y", float) = 500
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }

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
            float _PixelNumberX;
            float _PixelNumberY;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                // billboard仕様
                // o.vertex = mul(UNITY_MATRIX_P, mul(UNITY_MATRIX_MV, float4(0, 0, 0, 1)) + float4(v.vertex.x, v.vertex.y, 0, 0));
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                half ratioX = 1 / _PixelNumberX;
                half ratioY = 1 / _PixelNumberY;
                // sin/cosを使ってuvスクロール&波打ちシェーダにしてみた
                half2 moveUv = half2(i.uv.x + _Time.x, i.uv.y + sin(i.uv.x + _Time.y) * cos(i.uv.x + _Time.y) * 0.5);
                half x = (int)(moveUv.x / ratioX) * ratioX;
                half y = (int)(moveUv.y / ratioY) * ratioY;
                half2 uv = half2(x, y);
                return tex2D(_MainTex, uv);
            }
            ENDCG
        }
    }
}
