generate-data:
	python3 src/data/generate_dataset.py

run-all: generate-data

test:
	python3 -m pytest tests/ -v

clean:
	rm -f data/raw/*.csv data/processed/*.csv

