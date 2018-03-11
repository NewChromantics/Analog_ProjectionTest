using UnityEngine;
using System.Collections;
using System.Collections.Generic;


public class RenderToCubemap : MonoBehaviour {

	private const int TOP=0;
	private const int BOTTOM=1;
	private const int LEFT=2;
	private const int RIGHT=3;
	private const int FRONT=4;
	private const int BACK=5;
	private const int COUNT = 6;

	public Transform	ParentPosition = null;
	public bool oneFacePerFrame = false;
	public LayerMask lMas;

	public Camera CameraTop;
	public Camera CameraBottom;
	public Camera CameraLeft;
	public Camera CameraRight;
	public Camera CameraFront;
	public Camera CameraBack;
	public RenderTexture TextureTop;
	public RenderTexture TextureBottom;
	public RenderTexture TextureLeft;
	public RenderTexture TextureRight;
	public RenderTexture TextureFront;
	public RenderTexture TextureBack;
	private HideFlags NewCameraHideFlags = HideFlags.None;
	public CameraClearFlags ClearMode = CameraClearFlags.Color;

	private Camera[]		mCameras
	{
		get { return new Camera[COUNT]{CameraTop,CameraBottom,CameraLeft,CameraRight,CameraFront,CameraBack};	}
	}
	private RenderTexture[]		mTextures
	{
		get { return new RenderTexture[COUNT]{TextureTop,TextureBottom,TextureLeft,TextureRight,TextureFront,TextureBack};	}
	}

	private Vector3[]	mCameraRotations = new Vector3[COUNT] 
	{	
		new Vector3(-90,0,0), 
		new Vector3(90,0,0),
		new Vector3(0,-90,0), 
		new Vector3(0,90,0), 
		new Vector3(0,0,0), 
		new Vector3(0,180,0) 
	};

	//	gr: cannot get a ref/pointer to the member, so have to write to the member explicitly :/
	void SetCameraX(int CameraIndex,Camera Value)
	{
		switch (CameraIndex) {
		case TOP:
			CameraTop = Value;
			return;
		case BOTTOM:
			CameraBottom = Value;
			return;
		case LEFT:
			CameraLeft = Value;
			return;
		case RIGHT:
			CameraRight = Value;
			return;
		case FRONT:
			CameraFront = Value;
			return;
		case BACK:
			CameraBack = Value;
			return;
		}
		throw new System.Exception ("Invalid camera index");
	}

	void OnDisable()
	{
		//	delete cameras we created
		/*
		for (int f=0; f<COUNT; f++) {
			if (mCameras [f] == null)
				continue;
			if (mCameras [f].hideFlags != NewCameraHideFlags)
				continue;
			DestroyObject( mCameras[f].gameObject );
			SetCameraX (f, null);
		}*/
	}

	void InitCamera(Camera camera,RenderTexture TargetTexture,Vector3 RotationEular)
	{
		camera.transform.localRotation = Quaternion.Euler (RotationEular);
		//Debug.Log (camera.transform.rotation);
		camera.cullingMask = lMas;
		camera.targetTexture = TargetTexture;
		camera.clearFlags = ClearMode;
		//camera.clearFlags = CameraClearFlags.Depth;
		camera.backgroundColor = Color.green;
		camera.renderingPath = RenderingPath.Forward; //Change this later to get pretty graphics
		camera.farClipPlane = 100; // don't render very far into cubemap
		camera.enabled = false;
		camera.fieldOfView = 90;
	}

	void MakeCamera(int CameraIndex,RenderTexture TargetTexture)
	{
		//	no camera if no target texture
		if (!TargetTexture)
			return;

		GameObject go = new GameObject ("CubemapCamera_" + TargetTexture.name);
		//Debug.Log ("creating new camera:" + go.name + " on " + this.name);
		go.transform.SetParent (this.transform,false);
	
		Camera camera = go.AddComponent<Camera>();
		SetCameraX (CameraIndex,camera);
		go.hideFlags = NewCameraHideFlags;
	}

	// Use this for initialization
	void Start () {
		//	if no cameras assigned, make some
		for ( int f=0;	f<COUNT;	f++ )
		{
			if (mCameras[f] == null)
				MakeCamera (f, mTextures[f] );

			if (mCameras[f] == null)
				continue;

			InitCamera( mCameras[f], mTextures[f], mCameraRotations[f] );

			//	init content
			RenderCubemap (f);
		}
	}

	void RenderCubemap(int Index)
	{
		if (mCameras [Index] == null)
			return;
		RenderCubemap (mCameras [Index]);
	}

	void RenderCubemap(Camera camera)
	{
		//Debug.Log ("Rendering " + camera.name + " to " + camera.targetTexture.name);
		var OldRT = RenderTexture.active;
		RenderTexture.active = camera.targetTexture;
		camera.Render ();
		camera.targetTexture = RenderTexture.active;
	}

	void Update()
	{
		//	follow parent
		if (ParentPosition != null)
			transform.position = ParentPosition.position;
		LateUpdate ();
	}

	void LateUpdate () {
#if UNITY_EDITOR
		if (!UnityEditor.EditorApplication.isPlaying)
			return;
#endif
		if (oneFacePerFrame) {
			RenderCubemap (Time.frameCount % COUNT);
		} else {
			for ( int f=0;	f<COUNT;	f++ )
			{
				RenderCubemap(f);
			}
		}
	}


}
