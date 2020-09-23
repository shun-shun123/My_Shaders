Shader "Unlit/BlendTextureShader"
{
    Properties
    {
        _MainTex ("Main Texture", 2D) = "white" {}
        _SubTex ("Sub Texture", 2D) = "white" {}
        _MaskTex ("Mask Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

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
            sampler2D _SubTex;
            sampler2D _MaskTex;

            // TRANSFORM_TEXをするために必要なタイリングやオフセット情報のこと
            // {texture_name}_STで取得できる
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 mainCol = tex2D(_MainTex, i.uv);
                fixed4 subCol = tex2D(_SubTex, i.uv);
                fixed4 maskCol = tex2D(_MaskTex, i.uv);
                // lerp(x, y, s) x + s(y - x): 線形補間
                fixed4 col = lerp(mainCol, subCol, maskCol);
                return col;
            }
            ENDCG
        }
    }
}
