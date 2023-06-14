using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TMPro;

public class Coin : MonoBehaviour
{
    public TextMeshProUGUI coinText;
    public Animator anim;

    public GameObject[] coin3d;

    public void Active(int _coin)
    {
        coinText.text = "+$" + _coin;
        anim.SetTrigger("Active");
        StartCoroutine(C_Coin3D());
    }

    private IEnumerator C_Coin3D()
    {
        GameObject _c3d = GetCoin3D();
        _c3d.SetActive(true);
        yield return new WaitForSeconds(0.4f);
        _c3d.SetActive(false);
    }

    private GameObject GetCoin3D()
    {
        for(int i = 0; i < coin3d.Length; i++)
        {
            if (coin3d[i].activeSelf == false) return coin3d[i];
        }

        return coin3d[0];
    }
}
