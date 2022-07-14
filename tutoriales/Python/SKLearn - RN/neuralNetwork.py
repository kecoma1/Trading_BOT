from sklearn.neural_network import MLPClassifier
import numpy as np

data = np.genfromtxt('xor.csv', delimiter=',')
X = data[:, [0, 1]]
y = data[:, -1]

rn = MLPClassifier(hidden_layer_sizes=(2,), activation='logistic', max_iter=1000, alpha=0.001)

rn.fit(X, y)

for i in range(4):
    print(X[i], '->', rn.predict([X[i]]))