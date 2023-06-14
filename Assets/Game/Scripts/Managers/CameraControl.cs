using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraControl : MonoBehaviour
{
    public RectTransform[] top;

    void Start()
    {
        SetFOV();
    }

    void SetFOV()
    {
        float ratio = Camera.main.aspect;

        if (ratio >= 0.74) // 3:4
        {
            Camera.main.fieldOfView = 60;
        }
        else if (ratio >= 0.56) // 9:16
        {
            Camera.main.fieldOfView = 60;
        }
        else if (ratio >= 0.45) // 9:19
        {
            Camera.main.fieldOfView = 70;

            for(int i = 0; i < top.Length;i++)
            {
                Vector2 a = top[i].anchoredPosition;
                a.y -= 100.0f;
                top[i].anchoredPosition = a;
            }
        }
    }

}