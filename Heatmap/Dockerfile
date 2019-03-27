FROM python:3.7-alpine
    WORKDIR /Heatmap
    COPY . /Heatmap
    RUN pip install -r requirements.txt
    EXPOSE 80
CMD ["python", "heatmap.py"]
