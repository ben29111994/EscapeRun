using NWH.VehiclePhysics;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Player : MonoBehaviour
{
    public SwipeControl swipeControl;
    public VehicleController vehicleController;
    public float horizontalDeltaSpeed;
    bool _hold;
    bool isSet;
    private Vector3 pos1,pos2;
    private float timeCountDown;

    public bool isV;

    public void Start()
    {
        if (isV == false)
        {
            StartCoroutine(C_IsV());
        }
    }

    private void OnEnable()
    {
        Vector3 a = transform.eulerAngles;
        a.y = 0.0f;
        transform.eulerAngles = a;
    }

    private IEnumerator C_IsV()
    {
        vehicleController.input.Vertical = 1;

        isV = true;
        yield return new WaitForSeconds(3.0f);
        isV = false;
        gameObject.SetActive(false);
    }

    private void Update()
    {
        if (isV) return;

        if (isSet == false)
        {
            isSet = true;
            pos1 = transform.position;
            timeCountDown = 1.5f;
        }

        pos2 = transform.position;

        if (isSet)
        {
            timeCountDown -= Time.deltaTime;

            float distance = Vector3.Distance(pos1, pos2);

            if(timeCountDown <= 0)
            {
                if(distance <= 2)
                {
                    GameManager.Instance.Fail();
                }
                else
                {
                    isSet = false;
                }
            }
        }


        if (GameManager.Instance.isComplete) return;

        MoveControl();
    }


    public float x = 0.0f;

    private void MoveControl()
    {
        float x = swipeControl.deltaTouchFixed.x * 0.2f;
        vehicleController.input.Horizontal = x;

        float v = (swipeControl.isHold) ? 1 : 0;
        vehicleController.input.Vertical = 1;
    }

    private void FixedUpdate()
    {
        if (isV) return;

        CameraFollow();
    }

    private void CameraFollow()
    {
        Vector3 tarPos = GameManager.Instance.offsetCamera.position;
        tarPos.z = transform.position.z;
        GameManager.Instance.offsetCamera.position = Vector3.Lerp(GameManager.Instance.offsetCamera.position, tarPos, 4 * Time.deltaTime);
    }
}
