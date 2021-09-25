using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace ImageEffect.Painting {
    [ExecuteInEditMode]
    public class AbstractContrastPainting : MonoBehaviour
    {
        public bool debugColorfulFractal = false;
        public Shader shader;
        public Color sobelLineColor = Color.black;
        [Range(0, 30)] public float contrast = 2f;
        public float sobelDeltaX = 0.003f;
        public float sobelDeltaY = 0.015f;
        
        private ColorfulFractal colorfulFractal;
        private Material material;

        protected void Start()
        {
            this.colorfulFractal = this.GetComponent<ColorfulFractal>();
        }

        protected void OnRenderImage(RenderTexture src, RenderTexture dst)
        {
            if (this.material == null) { this.material = new Material(this.shader); }
            this.material.SetTexture("_ColorfulFractalTex", this.colorfulFractal.ColorfulFractalTex);
            this.material.SetColor("_SobelLineColor", this.sobelLineColor);
            this.material.SetFloat("_SobelDeltaX", this.sobelDeltaX);
            this.material.SetFloat("_SobelDeltaY", this.sobelDeltaY);
            this.material.SetFloat("_Contrast", this.contrast);
            if (this.debugColorfulFractal)
                this.material.EnableKeyword("DEBUG_COLORFUL_FRACTAL");
            else
                this.material.DisableKeyword("DEBUG_COLORFUL_FRACTAL");

            Graphics.Blit(src, dst, this.material);
        }

    }
}
