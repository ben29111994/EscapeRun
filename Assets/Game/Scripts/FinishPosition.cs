using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FinishPosition : MonoBehaviour
{
    public GameObject arrow;

    private void Start()
    {
        Destroy(transform.GetChild(0).gameObject);
        GameObject c = Instantiate(GameManager.Instance.areafinish,transform);
        GameManager.Instance.finishTransform = transform;

        arrow = c.transform.GetChild(0).gameObject;
    }
}
