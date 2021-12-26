#include <cstdlib>
#include <cstdio>
#include <iostream>
#include <time.h>


using namespace std;

class NeuralNetwork {
	private:
		short layers;					// Number of layers in the neural network
		short *layersConfig; 			// Vector with the number of neurons in each layer
		double **weights;				// Matrix with the weights
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

	public:
		/**
		 * @brief Construct a new Neural Network object
		 * 
		 * @param layersConfig Vector with the configuration of
		 * each layer.
		 */
		NeuralNetwork(short layers,short *layersConfig, bool show=false) {
			this->layersConfig = layersConfig;
			this->layers = layers;

			// Initializing the weights
			this->weights = (double**)malloc(this->layers*sizeof(double*));
			if (this->weights == NULL)
				fprintf	(stderr, "[ERROR-1] In the constructor of NeuralNetwork, initializing the weights\n");

			for (short i = 0; i < this->layers; i++) {
				this->weights[i] = (double*)malloc(this->layersConfig[i]*sizeof(double));
				if (this->weights[i] == NULL)
					fprintf(stderr, "[ERROR-2] In the constructor of NeuralNetwork, initializing each weights\n");

				if (this->show) fprintf(stdout, "Weights layer %d:\n", i);
				for (short n = 0; n < this->layersConfig[i]; n++) {
					this->weights[i][n] =  this->Rand(-1, 1);
					if (this->show) fprintf(stdout, " %f ", this->weights[i][n]);
				if (this->show) fprintf(stdout, "\n");
				}
			}
		}

		/**
		 * @brief Destroy the Neural Network object
		 * 
		 */
		~NeuralNetwork() {
			for (short i = 0; i < this->layers; i++)
				free(this->weights[i]);
			free(this->weights);
			if (this->show) fprintf(stdout, "Destroying the NeuralNetwork\n");
		}
};


int main() {
	/* initialize random seed: */
	srand(time(NULL));
	short layersConfig[] = {2, 3, 4}; 
	NeuralNetwork nn(3, layersConfig, true);
	return 0;
}