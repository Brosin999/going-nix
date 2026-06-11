# docker run -d --name tabby --device nvidia.com/gpu=all --restart no   -p 8080:8080 -v $HOME/.tabby:/data   registry.tabbyml.com/tabbyml/tabby serve   --model Qwen2.5-Coder-3B   --device cuda
sudo podman run -d --replace --name tabby \
  --device nvidia.com/gpu=all \
  --restart no \
  -p 8080:8080 \
  -v $HOME/.tabby:/data \
  registry.tabbyml.com/tabbyml/tabby serve \
  --model Qwen2.5-Coder-3B \
  --device cuda
