using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Assertions;


namespace ImageEffect.Painting
{
    [ExecuteInEditMode]
    public class ColorfulFractal : MonoBehaviour
    {
		public int lod = 7;
		public Color[] colors = new Color[]{ new Color(1, 0, 0, 0), new Color(0, 1, 0, 0), new Color(0, 0, 1, 0), new Color(0, 0, 0, 1) };
		public Vector4 tiling = new Vector4(5, 5, 60, 0);
		public Vector4 offsetX = new Vector4(3, 13, 29, 43);
		public Vector4 offsetY = new Vector4(7, 19, 37, 53);
		public Vector4 gain = new Vector4(2, 0.5f, 0, 0);

		private Matrix4x4 colorMatrix;
        public RenderTexture ColorfulFractalTex { get; private set; }
        private float timeShiftScale = 0.001f;
		public Shader shader;
		private Material material;

        public static class ShaderIDs
        {
            public static int ColorMatrix = Shader.PropertyToID("_ColorMatrix");
            public static int FractalTiling = Shader.PropertyToID("_FractalTiling");
            public static int FractalOffsetX = Shader.PropertyToID("_OffsetX");
            public static int FractalOffsetY = Shader.PropertyToID("_OffsetY");
            public static int FractalGain = Shader.PropertyToID("_Gain");
            public static int TimeShift = Shader.PropertyToID("_TimeShift");
        }

        //protected override void OnRenderImage(RenderTexture source, RenderTexture destination)
		public void Update()
        {
			if (this.material == null) {
				this.material = new Material(this.shader);
			}

			this.UpdateMaterial();
        }
		
		void UpdateMaterial()
		{
			Assert.IsTrue(this.material != null, "GenrativeFractal's genFractMat is not assigned a material.");
            Assert.IsTrue(this.lod >= 0, "Change LOD. lod >= 0");

			var width = Screen.width >> this.lod;
			var height = Screen.height >> this.lod;
			if (ColorfulFractalTex == null || ColorfulFractalTex.width != width || ColorfulFractalTex.height != height) 
			{
				Debug.Log(string.Format("Init RenderTexture {0}x{1}", width, height));
				Release();
				ColorfulFractalTex = new RenderTexture(width, height, 0, RenderTextureFormat.ARGBHalf, RenderTextureReadWrite.Linear);
				ColorfulFractalTex.filterMode = FilterMode.Bilinear;
				ColorfulFractalTex.wrapMode = TextureWrapMode.Clamp;
				ColorfulFractalTex.name = "GenerativeFractal RTex";
			}

            for(int i = 0; i < 4; i++)
            {
                this.colorMatrix.SetColumn(i, this.colors[i]);
            }
            this.material.SetFloat(ShaderIDs.TimeShift, Time.time * timeShiftScale);
			this.material.SetMatrix(ShaderIDs.ColorMatrix, this.colorMatrix);
			this.material.SetVector(ShaderIDs.FractalTiling, this.tiling);
			this.material.SetVector(ShaderIDs.FractalOffsetX, this.offsetX);
			this.material.SetVector(ShaderIDs.FractalOffsetY, this.offsetY);
			this.material.SetVector(ShaderIDs.FractalGain, this.gain);
            
            //Graphics.Blit(src, dst, this.material);
            Graphics.Blit(null, this.ColorfulFractalTex, this.material);
            //Graphics.Blit(this.ColorfulFractalTex, destination);
		}
        
		void OnDestroy() 
		{
			this.Release();
		}

		public void Release() 
		{
			if (ColorfulFractalTex != null) 
			{
				ColorfulFractalTex.Release();
				ColorfulFractalTex = null;
			}
		}        
    }
}
