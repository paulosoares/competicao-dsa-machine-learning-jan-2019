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

echo "Aplicando algoritmo..."
rm -f $TEMPTRAINFILE $TEMPTESTFILE
$CMD weka.classifiers.meta.FilteredClassifier $FILTRO -F "weka.filters.unsupervised.attribute.Remove -R 1,6-9" -S 36 -W weka.classifiers.functions.SGD -- -F 0 -L 0.01 -R 1.0E-4 -E 500 -C 0.001 -S 1

$CMD weka.classifiers.meta.FilteredClassifier -classifications "$PREDICTIONS" $FILTRO -F "weka.filters.unsupervised.attribute.Remove -R 1,6-9" -S 36 -W weka.classifiers.functions.SGD -- -F 0 -L 0.01 -R 1.0E-4 -E 500 -C 0.001 -S 1
