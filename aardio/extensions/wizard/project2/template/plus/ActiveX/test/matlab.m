% MATLAB ���� COM ����
sample = actxserver('${COLIBRARY_PATH}.${COCLASS_NAME}');

% ����Add����
num = sample.Invoke("Add",1,3)

% ��ʾ���
disp(num);

% ��������
sample.SetAttr("key", 'value2')

% ��ȡ����
sample.GetAttr("key")

% ��������
set(sample, 'key', 'value'); 

% ��ȡ����
value = get(sample, 'key');
