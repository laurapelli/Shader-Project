Shader "Unlit/Hologram"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color("Color", Color) = (1,1,1,1)
        _AlphaTexture("Alpha Texture", 2D) = "white"{}
        _Scale("Scale", Float) = 1
        _ScrollSpeed("Scroll", Float) = 0

            // Glow effect variables
        _GlowIntensity("Glow Intensity", Range(0.01, 1.0)) = 0.5
            // Glitch Effect variables
        _GlitchSpeed("Glitch Speed", Range(0,50)) = 50.0
        _GlitchIntensity("Glitch Intensity", Range(0.01, 0.1)) = 0
    }
    SubShader
    {
        Tags 
        { 
            "RenderType"="Transparent" 
            //Render it on top of everything ( overlay )
            "Queue"="Overlay"
        }
        LOD 100



        Pass
        {
            // Disable the writing of the depth buffer usually used for transparent objects
            Zwrite Off

            // Enable blending
            // When graphics are rendered, after all shaders have executed and all textures have been applied, the pixels
            // are written to the screen.
            // How they are combined with taht is already on the screen is determined by the blend mode
            Blend SrcAlpha One
            // Only render the front of the model
            Cull Back

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };


            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 alphaCoord: TEXCOORD1;
                float3 viewDir: TEXCOORD2;
                float3 worldNormal : NORMAL;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _AlphaTexture;
            float4 _Color;
            float _Scale;
            float _ScrollSpeed;
            float _GlowIntensity;
            float _GlitchSpeed;
            float _GlitchIntensity;


            v2f vert (appdata v)
            {
                v2f o;

                v.vertex.z += sin(_Time * _GlitchSpeed * v.vertex.y) * _GlitchIntensity;
                // Projects the vertex of the model to the screen
                o.vertex = UnityObjectToClipPos(v.vertex);
                // We set the texture UVs
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);

                // We set the alpha teture UVs
                o.alphaCoord = UnityObjectToViewPos(v.vertex);

                o.alphaCoord.y += _Time * _ScrollSpeed;
                // We set the normals 
                o.worldNormal = UnityObjectToWorldNormal(v.normal); // La normal del mundo para que sigan haciendose en vertical
                o.viewDir = normalize(UnityWorldSpaceViewDir(o.alphaCoord.xyz));

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);

                // sample the alpha texture
                fixed4 alpha = tex2D(_AlphaTexture, i.alphaCoord.xyz * _Scale);
                // We set the alpha of the color
                col.a = alpha.a;

                col.rgb = col.rgb *( _Color.rgb + _GlowIntensity) ;

                return col;
            }
            ENDCG
        }
    }
}