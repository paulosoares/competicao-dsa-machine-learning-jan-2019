# Competição DSA de Machine Learning (Janeiro/2019)
O desafio tem o objetivo de prever e ocorrência de diabetes em mulheres com mais de 20 anos. Nesta solução foi utilizada a ferramenta [weka](https://www.cs.waikato.ac.nz/ml/weka/) para fazer a análise dos dos dados e a predição da base teste. Os resultados obtidos foram 0.9 no ranking público  e 0.78813 no ranking privado. (Ver [leardbord](https://kaggle.com/c/competicao-dsa-machine-learning-jan-2019/leaderboard))

## Pré-requisitos
- Java 11

## Metodologia
- Binarização do atributo **num_gestacoes** (0='sem gestação', 1='com gestação')
- Aplicação do algoritmo SGD com seleção de atributos que melhoravam a precisão. Foram tentadas todas as combinações de atributos e selecionados para avaliação do algoritmo os atributos: num_gestacoes_binarized, glicose, pressao_sanguinea, grossura_pele.
- Também foram testados os seeds de 1 a 100 e selecionado o seed 36 como o que trazia mais classificações corretas.

## Resultados

    Options: -F "weka.filters.unsupervised.attribute.Remove -R 1,6-9" -S 36 -W weka.classifiers.functions.SGD -- -F 0 -L 0.01 -R 1.0E-4 -E 500 -C 0.001 -S 1 

    === Classifier model (full training set) ===

    FilteredClassifier using weka.classifiers.functions.SGD -F 0 -L 0.01 -R 1.0E-4 -E 500 -C 0.001 -S -2115301365 on data filtered through weka.filters.unsupervised.attribute.Remove -R 1,6-9

    Filtered Header
    @relation 'treino-weka.filters.unsupervised.attribute.NumericToNominal-R10-weka.filters.unsupervised.attribute.NumericToBinary-R2-weka.filters.unsupervised.attribute.Remove-R1,6-9'

    @attribute num_gestacoes_binarized {0,1}
    @attribute glicose numeric
    @attribute pressao_sanguinea numeric
    @attribute grossura_pele numeric
    @attribute classe {0,1}

    @data


    Classifier Model
    Loss function: Hinge loss (SVM)

    classe = 

            -0.01   (normalized) num_gestacoes_binarized=1
     +       5.5573 (normalized) glicose
     +      -0.1993 (normalized) pressao_sanguinea
     +       0.5652 (normalized) grossura_pele
     -       3.97  

    Time taken to build model: 0.22 seconds

    Time taken to test model on training data: 0.02 seconds

    === Error on training data ===

    Correctly Classified Instances         441               73.5    %
    Incorrectly Classified Instances       159               26.5    %
    Kappa statistic                          0.3702
    Mean absolute error                      0.265 
    Root mean squared error                  0.5148
    Relative absolute error                 58.4816 %
    Root relative squared error            108.1681 %
    Total Number of Instances              600     


    === Detailed Accuracy By Class ===

                     TP Rate  FP Rate  Precision  Recall   F-Measure  MCC      ROC Area  PRC Area  Class
                     0,878    0,534    0,756      0,878    0,812      0,382    0,672     0,743     0
                     0,466    0,122    0,669      0,466    0,550      0,382    0,672     0,497     1
    Weighted Avg.    0,735    0,391    0,726      0,735    0,721      0,382    0,672     0,658     


    === Confusion Matrix ===

       a   b   <-- classified as
     344  48 |   a = 0
     111  97 |   b = 1
