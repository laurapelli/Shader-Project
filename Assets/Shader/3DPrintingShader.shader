Shader "Unlit/3DPrintingShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _PrintProgress ("Print Progress", Range(0, 1)) = 0.0
        _TopColor ("Top Highlight Color", Color) = (1, 0, 0, 1) // Default to red
        _HighlightThickness ("Highlight Thickness", Range(0.01, 0.1)) = 0.05
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
                float height : TEXCOORD1; // Pass vertex height
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _PrintProgress; // Printing progress (0 = hidden, 1 = fully printed)
            float4 _TopColor; // Color of the leading edge
            float _HighlightThickness; // Thickness of the highlight band

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.height = v.vertex.y; // Pass the vertex height in local space
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // Get the base color from the texture
                fixed4 col = tex2D(_MainTex, i.uv);

                // Apply 3D printing effect
                if (i.height > _PrintProgress)
                {
                    discard; // Make fragments above the progress invisible
                }

                // Apply highlight to the "leading edge"
                if (i.height > _PrintProgress - _HighlightThickness && i.height <= _PrintProgress)
                {
                    col = lerp(col, _TopColor, 0.5); // Blend the highlight color
                }

                return col;
            }
            ENDCG
        }
    }
}