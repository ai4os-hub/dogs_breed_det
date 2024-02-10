import groovy.transform.Field

@Field
def base_cpu_tag = '"1.12.0-py36"'
@Field
def base_gpu_tag = '1.12.0-gpu-py36'
@Field
def dockerfile_path = 'Dockerfile'

return this;