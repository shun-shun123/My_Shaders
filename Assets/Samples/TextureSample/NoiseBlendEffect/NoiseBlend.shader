Shader "Unlit/NoiseBlend"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Noise1Tex ("Noise1 Tex", 2D) = "white"{}
        _Noise2Tex ("Noise2 Tex", 2D) = "white"{}
        _MainTexSpeed ("MainTex Speed", Vector) = (0, 0, 0, 0)
        _MaskClipAlpha ("Mask Clip Alpha", Range(0.0, 1.0)) = 0.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Blend One OneMinusSrcAlpha

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
            fixed4 _MainTexSpeed;
            sampler2D _Noise1Tex;
            sampler2D _Noise2Tex;
            float _MaskClipAlpha;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            // [参考] https://qiita.com/yoya/items/96c36b069e74398796f3
            float rgbToGrayscale(fixed3 col) 
            {
                return col.r * 0.2126 + col.g * 0.7152 + col.b * 0.0722; 
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed2 mainTexUV = i.uv;
                mainTexUV.x += _Time.x * _MainTexSpeed.x;
                mainTexUV.y += _Time.x * _MainTexSpeed.y;
                fixed4 col = tex2D(_MainTex, mainTexUV);
                float gray = rgbToGrayscale(col);
                if (gray <= _MaskClipAlpha) {
                    discard;
                } 
                if (gray <= _MaskClipAlpha + 0.01) {
                    fixed r = _MaskClipAlpha + 0.01 - gray;
                    return fixed4(r * 100.0 + 0.1, r * 80.0 + 0.1, r * 40.0, 1);
                }

                fixed4 mask2 = tex2D(_Noise2Tex, i.uv + _Time);
                float mask2Gray = rgbToGrayscale(mask2);
                col.r *= mask2Gray * 2.0;
                return col;
            }
            ENDCG
        }
    }
}
