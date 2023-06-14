using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Test : MonoBehaviour
{
    public Bullet bulletPrefab;
    public List<Bullet> listBullet = new List<Bullet>();

    public void Start()
    {
        
    }

    private float currentTime;

    private void Update()
    {
        currentTime += Time.deltaTime;

        if(currentTime >= 0.04f)
        {
            currentTime = 0.0f;

            Bullet _b = GetBullet();
            _b.transform.position = transform.position + Vector3.up * 5.0f;
            _b.Shoot(Vector3.down);
        }
    }

    private void GenerateBullet()
    {
        for (int i = 0; i < 100; i++)
        {
            Bullet _bullet = Instantiate(bulletPrefab,transform).GetComponent<Bullet>();           
            _bullet.gameObject.SetActive(false);
            listBullet.Add(_bullet);
        }
    }

    private Bullet GetBullet()
    {
        for(int i = 0; i < listBullet.Count; i++)
        {
            Bullet _b = listBullet[i];
            if (_b.gameObject.activeSelf == false) return _b;
        }

        Bullet _obj = Instantiate(bulletPrefab,transform);
        _obj.gameObject.SetActive(false);
        listBullet.Add(_obj);
        return _obj;
    }
}
