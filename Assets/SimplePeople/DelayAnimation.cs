using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DelayAnimation : MonoBehaviour
{
    private void OnEnable()
    {
        StartCoroutine(C_Delay());
    }

    private IEnumerator C_Delay()
    {
        int r = Random.Range(0, 3);
        if(r == 0)
        {
            GetComponent<Animator>().SetTrigger("Wave");

        }
        else if ( r == 1)
        {
            GetComponent<Animator>().SetTrigger("Idle");

        }
        else if ( r== 2)
        {
            GetComponent<Animator>().SetTrigger("Smoke");

        }
        GetComponent<Animator>().speed = 0;
        yield return new WaitForSeconds(Random.Range(0.5f, 1.5f));
        GetComponent<Animator>().speed = 1;
    }
}
