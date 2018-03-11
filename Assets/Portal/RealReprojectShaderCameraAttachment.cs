using UnityEngine;
using System.Collections;


[ExecuteInEditMode]
public class RealReprojectShaderCameraAttachment : MonoBehaviour {

	public GameObject Camera;

	// Use this for initialization
	void Start () {
	
	}
	
	// Update is called once per frame
	void Update () {
	

		if ( Camera != null )
		{
			var r = gameObject.GetComponent<Renderer>();
			if ( r != null )
			{
				var mat = r.sharedMaterial;
				if ( mat != null )
				{
					mat.SetVector("CameraWorldPos", Camera.transform.position );
				}
			}
		}
	}
}
