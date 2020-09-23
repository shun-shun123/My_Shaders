Shader "Unlit/BlendModeSample"
{
    Properties
    {
    }
    SubShader
    {
        Tags { 
            "RenderType"="Transparent" 
            "Queue" = "Transparent"
        }
        LOD 100
        // Blend One Zero   // srcColorでそのまま上書きされる
        // Blend SrcColor Zero // srcColorの少し暗い色が出力される　
        // Blend SrcAlpha OneMinusSrcAlpha // 透明描画
        // Blend One OneMinusSrcAlpha  // 乗算済みアルファ（プリマルチプライド）描画
        // Blend One One // 追加
        // Blend OneMinusDstColor One  // ソフトな追加
        // Blend DstColor Zero // 乗算
        // Blend DstColor SrcColor // 2x乗算
        // Blend One OneMinusDstColor // 元の色を反転色にした上で追加

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

            fixed4 _MainColor;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = fixed4(i.uv.y, 1-i.uv.y, 0.0, 0.7);
                return col;
            }
            ENDCG
        }
    }
}
