using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FastFood : MonoBehaviour
{
    public static FastFood Instance;

    private List<GameObject> fastFoodType = new List<GameObject>();

    private void Awake()
    {
        Instance = this;
        
        for(int i = 0; i < transform.childCount;i++)
        {
            fastFoodType.Add(transform.GetChild(i).gameObject);
        }
    }

    public void ActiveFastFood(int index)
    {
        for(int i = 0; i < fastFoodType.Count; i++)
        {
            fastFoodType[i].SetActive(false);
        }

        if (index >= fastFoodType.Count) index = Random.Range(0, fastFoodType.Count);
        fastFoodType[index].SetActive(true);
    }
}