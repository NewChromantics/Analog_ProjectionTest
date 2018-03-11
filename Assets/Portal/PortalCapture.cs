using UnityEngine;
using System.Collections;

public class PortalCapture : MonoBehaviour {

	public Material PortalMaterial;
	public GameObject WorldPortal;
	public GameObject PortalCamera;
	public RenderTexture Target;

	public Vector3 PortalLocalTopLeft = new Vector3( -1, -1, 0 );
	public Vector3 PortalLocalTopRight = new Vector3(  1, -1, 0 );
	public Vector3 PortalLocalBottomLeft = new Vector3( -1,  1, 0 );
	public Vector3 PortalLocalBottomRight = new Vector3(  1,  1, 0 );

	void Update () {

		//	need to do a blit as if we're rendering the quad

		//	material needs to know the "world" corners of the portal
		var PortalWorldTopLeft = WorldPortal.transform.localToWorldMatrix * PortalLocalTopLeft;
		var PortalWorldTopRight = WorldPortal.transform.localToWorldMatrix * PortalLocalTopRight;
		var PortalWorldBottomLeft = WorldPortal.transform.localToWorldMatrix * PortalLocalBottomLeft;
		var PortalWorldBottomRight = WorldPortal.transform.localToWorldMatrix * PortalLocalBottomRight;
		PortalMaterial.SetVector ("WorldTopLeft", PortalWorldTopLeft);
		PortalMaterial.SetVector ("WorldTopRight", PortalWorldTopRight);
		PortalMaterial.SetVector ("WorldBottomLeft", PortalWorldBottomLeft);
		PortalMaterial.SetVector ("WorldBottomRight", PortalWorldBottomRight);
		PortalMaterial.SetVector ("CameraWorldPos", PortalCamera.transform.position);

		PortalMaterial.SetVector ("ObjectToWorldMatrix_0", WorldPortal.transform.localToWorldMatrix.GetRow(0));
		PortalMaterial.SetVector ("ObjectToWorldMatrix_1", WorldPortal.transform.localToWorldMatrix.GetRow(1));
		PortalMaterial.SetVector ("ObjectToWorldMatrix_2", WorldPortal.transform.localToWorldMatrix.GetRow(2));
		PortalMaterial.SetVector ("ObjectToWorldMatrix_3", WorldPortal.transform.localToWorldMatrix.GetRow(3));
		PortalMaterial.SetMatrix ("PortalToWorldMatrix", WorldPortal.transform.localToWorldMatrix);
		//PortalMaterial.SetMatrix ("PortalToWorldMatrix", Matrix4x4.identity);


		Graphics.Blit (null, Target, PortalMaterial);
	}
}
