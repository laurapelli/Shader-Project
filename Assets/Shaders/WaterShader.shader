Shader "Unlit/WaterShader"
{
    Properties
    {
        // Texturas y colores
        _WaterNormal ("Water Normal", 2D) = "bump" {}
        _ShallowColor ("Shallow Color", Color) = (0.7, 0.9, 1.0, 1)
        _DeepColor ("Deep Color", Color) = (0.7, 1, 1.0, 1)

        // Parámetros de ondas
        _NormalScale ("Normal Scale", Float) = 1.0
        _Distortion ("Distortion", Float) = 5
        _WaterDepth ("Water Depth", Float) = 1.0
        _WaterFalloff ("Water Falloff", Float) = 2.0

        // Parámetros visuales
        _WaterSpecular ("Water Specular", Float) = 0.5
    }
    SubShader
    {
        Tags 
        { 
            "RenderType"="Transparent"
            "Queue"="Transparent"
        }
        LOD 100

        Pass
        {
            // Configuración de renderizado
            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha
            Cull Back

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            // Estructuras
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

            // Uniformes
            sampler2D _WaterNormal;
            float4 _WaterNormal_ST;
            float _NormalScale;
            float _Distortion;
            float _WaterDepth;
            float _WaterFalloff;
            float4 _DeepColor;
            float4 _ShallowColor;
            float _WaterSpecular;

            v2f vert (appdata v)
            {
                v2f o;
                // Projects the vertex of the model to the screen
                o.vertex = UnityObjectToClipPos(v.vertex);
                // We set the texture UVs
                o.uv = TRANSFORM_TEX(v.uv, _WaterNormal);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // Generate animated normals
                // Offset the texture coordinates over time to simulate movement
                float2 uvOffset = i.uv + _Time.y * float2(0.1, 0.1); 
                // Extract normal map data and scale it by _NormalScale
                float3 normalMap = UnpackNormal(tex2D(_WaterNormal, uvOffset) * _NormalScale); 
                
                // Depth
                float depth = saturate(pow(_WaterDepth, _WaterFalloff)); 
                // Blend between shallow and deep water colors based on depth
                float4 waterColor = lerp(_ShallowColor, _DeepColor, depth); 

                // Distortion
                // Offset UV coordinates using the normal map and distortion factor
                float2 distortedUV = i.uv + normalMap.xy * _Distortion; 
                // Sample the normal map with distorted UV coordinates
                float4 distortionColor = tex2D(_WaterNormal, distortedUV); 

                // Combine colors and visual effect
                // Blend the water color with the distortion color based on depth
                fixed4 finalColor = lerp(waterColor, distortionColor, depth);  
                // Apply specular intensity to the RGB channels
                finalColor.rgb *= _WaterSpecular; 
                finalColor.a = 0.5; // Set fixed transparency

                return finalColor;
            }
            ENDCG
        }
    }
    Fallback "Diffuse"
}