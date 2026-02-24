 echo 'Installing Pillow for Linux AMD64...' && \
    pip install --quiet Pillow==10.4.0 -t /tmp/python/lib/python3.12/site-packages/ && \
    cd /tmp && \
    echo 'Creating layer zip file...' && \
    apt-get update -qq && apt-get install -y -qq zip > /dev/null 2>&1 && \
    zip -q -r pillow_layer.zip python/ && \
    cp pillow_layer.zip /output/ && \
    echo 'Layer built successfully for Linux (Lambda-compatible)!'
