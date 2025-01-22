install:
	pip install --upgrade pip &&\
		pip install -r requirements.txt

format:
	black *.py

train:
	python train.py

eval:
	echo "## Model Metrics" > report.md
	cat ./results/metrics.txt >> report.md
	echo '\n## Confusion Matrix Plot' >> report.md
	echo '![Confusion Matrix](./results/model_results.png)' >> report.md
	cml comment create report.md

update-branch:
	@if [ -z "$(USER_NAME)" ] || [ -z "$(USER_EMAIL)" ]; then \
		echo "Error: USER_NAME and USER_EMAIL must be provided"; \
		exit 1; \
	fi
	git config --global user.name "$(USER_NAME)"
	git config --global user.email "$(USER_EMAIL)"
	git add .  # Add all changes, including untracked files
	git commit -am "Update with new results" || echo "No changes to commit"
	git pull --rebase
	git push

hf-login: 
	pip install -U "huggingface_hub[cli]"
	git pull origin update
	git switch update
	huggingface-cli login --token $(HF) --add-to-git-credential

push-hub: 
	huggingface-cli upload MarkJamesDunbar/Drug-Classification ./app --repo-type=space --commit-message="Sync App files"
	huggingface-cli upload MarkJamesDunbar/Drug-Classification ./model /model --repo-type=space --commit-message="Sync Model"
	huggingface-cli upload MarkJamesDunbar/Drug-Classification ./results /metrics --repo-type=space --commit-message="Sync Model"

deploy: hf-login push-hub

all: install format train eval update-branch deploy