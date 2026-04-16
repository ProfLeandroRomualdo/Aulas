# Imagem oficial com Anaconda
FROM continuumio/anaconda3

# Atualiza pacotes (opcional, mas recomendado)
RUN conda update -n base -c defaults conda -y

# Instala Jupyter 
RUN conda install -y notebook

# Cria diretório de trabalho
WORKDIR /workspace

# Expõe a porta do Jupyter
EXPOSE 8888

# Comando para iniciar Jupyter sem token (para facilitar acesso local)
CMD ["jupyter", "notebook", "--ip=0.0.0.0", "--port=8888", "--no-browser", "--allow-root", "--NotebookApp.token=''", "--NotebookApp.password=''"]