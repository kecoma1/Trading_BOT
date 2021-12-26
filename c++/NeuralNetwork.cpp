#include <cstdlib>
#include <cstdio>
#include <iostream>
#include <time.h>
#include <math.h>

using namespace std;

class NeuralNetwork {
	private:
		short weightLayers;				// Number of weight layers in the neural network
		short *layersConfig; 			// Vector with the number of neurons in each layer
		double ***weights = NULL;		// Vector of matrixes with the weights
		bool show;						// Attribute to display messages

		/**
		 * @brief Private method to generate a random double.
		 * 
		 * @param min Minimum value.
		 * @param max Maximum value.
		 * @return double Random num
		 */
		double Rand(double min, double max) {
			double f = (double)rand() / RAND_MAX;
			return min + f * (max - min);
		}

		/**
		 * @brief Private method to calculate the sigmoid.
		 * 
		 * @param x 
		 * @return double result.
		 */
		double sigmoid(int x) { return 1/(1+exp(-x)); }

	public:
		
		/**
		 * @brief Construct a new Neural Network object.
		 * 
		 * @param weightLayers Number of weight layers (number of weight matrix).
		 * @param layersConfig 
		 * @param show 
		 */
		NeuralNetwork(short weightLayers, short *layersConfig, bool show=false) {
			this->layersConfig = layersConfig;
			this->weightLayers = weightLayers;

			for (int i = 0; i < weightLayers+1; i++) printf(" %d ", layersConfig[i]);
			printf("\n");

			// Initializing the weights
			this->weights = (double***)malloc((this->weightLayers)*sizeof(double**));
			if (this->weights == NULL)
				fprintf	(stderr, "[ERROR-1] In the constructor of NeuralNetwork, initializing the weights\n");

			for (short i = 0; i < this->weightLayers; i++) {
				if (this->show) printf("Weights %d:\n", i);

				// 1+  because of the bias
				this->weights[i] = (double**)malloc(1+(this->layersConfig[i])*sizeof(double*));
				if (this->weights == NULL)
					fprintf	(stderr, "[ERROR-2] In the constructor of NeuralNetwork, initializing the weights\n");

				for (short n = 0; n < this->layersConfig[i]+1; n++) {
					this->weights[i][n] = (double*)malloc(this->layersConfig[i+1]*sizeof(double));
					if (this->weights == NULL)
						fprintf	(stderr, "[ERROR-3] In the constructor of NeuralNetwork, initializing the weights\n");
					for (short j = 0; j < this->layersConfig[i+1]; j++) {
						this->weights[i][n][j] = this->Rand(-1, 1);
						if (this->show) printf("%d-%d %f\n", n, j, this->weights[i][n][j]);
					}
				}
			}
		}

		/**
		 * @brief Destroy the Neural Network object
		 * 
		 */
		~NeuralNetwork() {
			if (this->show) fprintf(stdout, "Destroying the NeuralNetwork\n");
			if (this->weights != NULL) {
				for (short i = 0; i < this->weightLayers; i++) {
					for (short n = 0; n < this->layersConfig[i]+1; n++) 
						if (this->weights[i][n] != NULL) 
							free(this->weights[i][n]);
					if (this->weights[i] != NULL) free(this->weights[i]);
				}
				if (this->weights) free(this->weights);
			}
		}
};


int main() {
	/* Example:
		2		3			4			1
		Inputs	LAYER 1 	LAYER 2		OUTPUT
		X		·			·			·
				·			·
		Y		·			·
							·
		bias	bias		bias

		This neural network has 2 hidden layers. You need to send to
		the constructor all the information, number of inputs and number of outputs.
		We have here 3 weight matrixes.
	*/

	/* initialize random seed: */
	srand(time(NULL));
	short layersConfig[] = {2, 3, 1, 1}; // 2 inputs ... 1 output
	NeuralNetwork nn(3, layersConfig, true); // You have to send the number of layers of weights.
	return 0;
}