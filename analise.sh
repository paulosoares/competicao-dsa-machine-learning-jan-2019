#!/bin/bash
TRAINFILECSV="treino.csv"
TESTFILECSV="teste.csv"
SUBMISSIONFILE="submission.csv"

### variáveis auxiliares
WEKA=weka.jar
TRAINFILE="train.arff"
TESTFILE="test.arff"
TEMPTRAINFILE="temp_train.arff"
TEMPTESTFILE="temp_test.arff"
JAVA_OPTS="--add-opens=java.base/java.lang=ALL-UNNAMED --add-opens=java.base/java.lang.invoke=ALL-UNNAMED"
FILTRO="-t $TRAINFILE -T $TESTFILE"
CMD="java $JAVA_OPTS -cp $WEKA"
IOTRAIN="-i $TEMPTRAINFILE -o $TRAINFILE"
IOTEST="-i $TEMPTESTFILE -o $TESTFILE"
PREDICTIONS="weka.classifiers.evaluation.output.prediction.CSV -p first -file predictions.csv"

### Manipulações nas bases

rm -f $TRAINFILE $TESTFILE $TEMPTRAINFILE $TEMPTESTFILE

echo "Gerando base de treinamento..."
$CMD weka.core.converters.CSVLoader $TRAINFILECSV > $TRAINFILE

echo "Gerando base de teste..."
$CMD weka.core.converters.CSVLoader $TESTFILECSV > $TESTFILE

echo "Convertendo o atributo 'classe' para nominal"
mv $TRAINFILE $TEMPTRAINFILE && mv $TESTFILE $TEMPTESTFILE
$CMD weka.filters.unsupervised.attribute.NumericToNominal -R 10 $IOTRAIN

echo "Adicionando o atributo classe na base de teste"
$CMD weka.filters.unsupervised.attribute.Add -T NOM -N classe -L 0,1 -C last -W 1.0 $IOTEST

echo "Binarizando o atributo num_gestacoes"
mv $TRAINFILE $TEMPTRAINFILE && mv $TESTFILE $TEMPTESTFILE
$CMD weka.filters.unsupervised.attribute.NumericToBinary -R 2 $IOTRAIN
$CMD weka.filters.unsupervised.attribute.NumericToBinary -R 2 $IOTEST
$CMD weka.filters.unsupervised.attribute.RenameAttribute -find \(.*\) -replace num_gestacoes -R 2 $IOTRAIN
$CMD weka.filters.unsupervised.attribute.RenameAttribute -find \(.*\) -replace num_gestacoes -R 2 $IOTEST

# Os passos abaixo foram comentados porque o algoritmo usado já faz o tratamento de missing values e normalização

#echo "Convertendo zeros em missing values nos campos 'pressao sanguinea' e 'bmi'"
#mv $TRAINFILE $TEMPTRAINFILE && mv $TESTFILE $TEMPTESTFILE
#$CMD weka.filters.unsupervised.attribute.NumericCleaner -min 1.0 -min-default NaN -R 4,7 -decimals -1 $IOTRAIN
#$CMD weka.filters.unsupervised.attribute.NumericCleaner -min 1.0 -min-default NaN -R 4,7 -decimals -1 $IOTEST

#echo "Injetando a média nos missing values"
#mv $TRAINFILE $TEMPTRAINFILE && mv $TESTFILE $TEMPTESTFILE
#$CMD weka.filters.unsupervised.attribute.ReplaceMissingValues $IOTRAIN
#$CMD weka.filters.unsupervised.attribute.ReplaceMissingValues $IOTEST

#echo "Normalizando dados dos atributos"
#mv $TRAINFILE $TEMPTRAINFILE && mv $TESTFILE $TEMPTESTFILE
#$CMD weka.filters.unsupervised.attribute.Normalize -S 1.0 -T 0.0 $IOTRAIN
#$CMD weka.filters.unsupervised.attribute.Normalize -S 1.0 -T 0.0 $IOTEST

echo "Aplicando algoritmo..."
rm -f $TEMPTRAINFILE $TEMPTESTFILE
$CMD weka.classifiers.meta.FilteredClassifier -classifications "$PREDICTIONS" $FILTRO -F "weka.filters.unsupervised.attribute.Remove -R 1,6-9" -S 36 -W weka.classifiers.functions.SGD -- -F 0 -L 0.01 -R 1.0E-4 -E 500 -C 0.001 -S 1 > /dev/null

echo "Gerando $SUBMISSIONFILE para o kaggle"
cat predictions.csv | awk '!/^$/' | awk -F, '{!/^$/;gsub("predicted","classe",$3);gsub("1:|2:","",$3); print $6","$3}' > $SUBMISSIONFILE
rm -f predictions.csv
echo "Para submeter o arquivo, execute: kaggle competitions submit -c competicao-dsa-machine-learning-jan-2019 -f $SUBMISSIONFILE -m 'MENSAGEM'"
