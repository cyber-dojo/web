mkdir steps
cp *_steps.py steps
behave --no-color
rm -rf steps
