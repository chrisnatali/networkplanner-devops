ec2run --block-device-mapping /dev/sda1=:128 -g np-c -k _keyname_ ami-82fa58eb
ec2tag i-7d5ddd01 --tag Name=np_cs
