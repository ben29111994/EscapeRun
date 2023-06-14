using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.SceneManagement;

public class UIManager : MonoBehaviour
{
    public static UIManager Instance;

    private void Awake()
    {
        Instance = this;
    }

    [Header("References")]
    public GameObject MainMenuUI;
    public GameObject InGameUI;
    public GameObject CompleteUI;
    public GameObject FailUI;
    public GameObject SwipeToPlay;
    public InputField ipf;

    public ParticleSystem[] fireworks;

    private void Start()
    {
        Coin += 0;
        Show_MainMenuUI();
    }

    private void Update()
    {
        if (Input.GetKeyDown(KeyCode.L)) Show_FailUI();
    }

    public void Show_MainMenuUI()
    {
        MainMenuUI.SetActive(true);
        InGameUI.SetActive(false);
        CompleteUI.SetActive(false);
        FailUI.SetActive(false);

        SwipeToPlay.SetActive(false);
    }

    public void Show_InGameUI()
    {
        StartCoroutine(C_Show_InGameUI());
    }

    public void ShowCompleteUI()
    {
        MainMenuUI.SetActive(false);
        InGameUI.SetActive(false);
        CompleteUI.SetActive(true);
        FailUI.SetActive(false);
    }

    public void Show_FailUI()
    {
        MainMenuUI.SetActive(false);
        InGameUI.SetActive(false);
        CompleteUI.SetActive(false);
        FailUI.SetActive(true);
    }

    private IEnumerator C_Show_InGameUI()
    {
        MainMenuUI.SetActive(false);

        yield return new WaitForSeconds(1.5f);

        SwipeToPlay.SetActive(true);

        InGameUI.SetActive(true);
        CompleteUI.SetActive(false);
        FailUI.SetActive(false);

        yield return new WaitForSeconds(2.0f);

        SwipeToPlay.SetActive(false);
    }

    public void Firework()
    {
        for(int i = 0; i < fireworks.Length; i++)
        {
            fireworks[i].Play();
        }
    }

    public Text coinText;
    public int Coin
    {
        get
        {
            return PlayerPrefs.GetInt("Coin");
        }
        set
        {
            PlayerPrefs.SetInt("Coin", value);
            coinText.text = value.ToString();
        }
    }

    public void OnClick_LoadScene()
    {
        SceneManager.LoadScene(0);
    }

    public void LoadLevel()
    {
        int lvl = 0;

        try
        {
            string _s = ipf.text;

            lvl = int.Parse(_s);
        }
        catch
        {
            lvl = 0;
        }

        lvl--;
        PlayerPrefs.SetInt("levelGame", lvl);
        SceneManager.LoadScene(0);
    }
}
