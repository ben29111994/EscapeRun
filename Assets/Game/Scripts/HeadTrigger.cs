using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class HeadTrigger : MonoBehaviour
{
    private void OnTriggerEnter(Collider other)
    {
        if (other.CompareTag("BigCar") || other.CompareTag("Wall") || other.CompareTag("Ground"))
        {
            GameManager.Instance.Fail();
        }
    }
}