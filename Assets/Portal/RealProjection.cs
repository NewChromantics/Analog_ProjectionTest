using UnityEngine;
using System.Collections;
using System.Collections.Generic;


[ExecuteInEditMode]
public class RealProjection : MonoBehaviour {

	public enum ProjectionModeEnum { Real, Debug, Measure };

	public ProjectionModeEnum 	ProjectionMode = ProjectionModeEnum.Real;
	public List<Camera>			Projectors;
	public Material				MeasureShader = null;
	public Material				DebugShader = null;
	public Material				RealShader = null;

	void UpdateMaterial(Material material)
	{
		if (!material)
			return;
	
		material.SetInt ("FrustumCount", 0);
		if (Projectors==null)
			return;
		
		int ProjectorIndex = 0;
		//	for each projector, pass it's frustum planes into the shader
		for (int p=0; p<Projectors.Count; p++) 
		{
			Camera projector = Projectors [p];
			if ( !projector )
				continue;
			Plane[] FrustumPlanes = GeometryUtility.CalculateFrustumPlanes (projector);
			
			//	order: http://answers.unity3d.com/questions/454457/which-plane-is-which-with-calculatefrustumplanes.html
			//	gr: luckily 0-3 are the ones we want :)
			for (int PlaneIndex=0; PlaneIndex<4; PlaneIndex++) 
			{
				Plane FrustumPlane = FrustumPlanes [PlaneIndex];
				Vector4 FrustumPlane4 = new Vector4 (FrustumPlane.normal.x, FrustumPlane.normal.y, FrustumPlane.normal.z, FrustumPlane.distance);
				material.SetVector ("Frustum" + ProjectorIndex + PlaneIndex, FrustumPlane4);
			}
			
			material.SetInt ("FrustumCount", ProjectorIndex+1);
			ProjectorIndex++;
		}	
	}

	Material GetProjectionMaterial()
	{
		if (ProjectionMode == ProjectionModeEnum.Measure && MeasureShader != null)
			return MeasureShader;

		if (ProjectionMode == ProjectionModeEnum.Debug && DebugShader != null)
			return DebugShader;

		return RealShader;
	}

	void Update () 
	{
		Renderer RealProjectionRenderer = this.gameObject.GetComponent<Renderer> ();
		if (RealProjectionRenderer!=null ) 
		{
			RealProjectionRenderer.sharedMaterial = GetProjectionMaterial();
			UpdateMaterial (RealProjectionRenderer.sharedMaterial);
		}
	}
}
