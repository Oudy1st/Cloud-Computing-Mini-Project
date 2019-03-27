FROM python:3.7

WORKDIR /Heatmap
COPY . /Heatmap

COPY requirements.txt requirements.txt

RUN pip install --upgrade pip
RUN pip install -r requirements.txt

COPY . .

EXPOSE 8080

CMD ["python", "heatmap.py"]
