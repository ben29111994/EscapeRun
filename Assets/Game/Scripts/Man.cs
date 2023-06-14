using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class Man : MonoBehaviour
{
    public Text manText;

    public void Active(string _text)
    {
        manText.text = _text;
        gameObject.SetActive(true);
        StartCoroutine(C_Delay());
    }

    private IEnumerator C_Delay()
    {
        yield return new WaitForSeconds(2.0f);
        gameObject.SetActive(false);
    }
}
