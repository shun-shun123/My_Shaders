Shader "Unlit/Scanline"
{
    Properties
    {
        _MainTex ("Main Texture", 2D) = "white" {}
        _NoiseTex ("Noise Texture", 2D) = "white" {}
        _BlendRatio ("Blend Ratio", Range(0, 1)) = 0.75
        _ScanlineDetail ("Scanline Detail", float) = 100.0
        _NumOfScanline ("Num of scanlines", float) = 20.0
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

            sampler2D _MainTex;
            sampler2D _NoiseTex;

            float4 _MainTex_ST;
            float4 _NoiseTex_ST;

            float _BlendRatio;
            float _ScanlineDetail;
            float _NumOfScanline;

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
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                fixed4 noise = tex2D(_NoiseTex, i.uv * _NoiseTex_ST.xy);

                fixed y = floor((i.uv.y + _Time.y * 0.1) * _ScanlineDetail);
                if (y % _NumOfScanline == 0) {
                    return (_BlendRatio * col) + (noise * (1 -_BlendRatio));
                }
                col.rb *= 0.8;
                col.g *= 1.0;
                return col;
            }
            ENDCG
        }
    }
}
