% This function is the primary driver for homework 3 part 1
function l31
close all;
clear all;
clc;
% we will experiment with a simple 2d dataset to visualize the decision
% boundaries learned by a MLP. Our goal is to study the changes to the
% decision boundary and the training error with respect to the following
% parameters
% - increasing the number of training iterations
% - increase the number of hidden layer neurons
% - see the effect of learning rate on the convergence of the network


% centroid for the three classes
c1=[1 1];
c2=[3 1];
c3=[2 3];

% standard deviation for the three classes
% "increase this quantity to increase the overlap between the classes"
sd=0.2;

% number of data points per class
N=100;

rand('seed', 1);

% generate data points for the three classes
x1=randn(N,2)*sd+ones(N,1)*c1;
x2=randn(N,2)*sd+ones(N,1)*c2;
x3=randn(N,2)*sd+ones(N,1)*c3;

% generate the labels for the three classes in the binary notation
y1= repmat([1 0 0],N,1);
y2= repmat([0 1 0],N,1);
y3= repmat([0 0 1],N,1);

% creating the test data points
a1min = min([x1(:,1);x2(:,1);x3(:,1)]);
a1max = max([x1(:,1);x2(:,1);x3(:,1)]);

a2min = min([x1(:,2);x2(:,2);x3(:,2)]);
a2max = max([x1(:,2);x2(:,2);x3(:,2)]);

[a1 a2] = meshgrid(a1min:0.1:a1max, a2min:0.1:a2max);

testX=[a1(:) a2(:)];

% Experimenting with MLP

% number of epochs for training
prompt = 'Enter the number of trainig epochs - ';
nEpochs = input(prompt);

% learning rate
prompt = 'Enter the learning rate - ';
eta = input(prompt);

% number of hidden layer units
prompt = 'Enter the number of hidden layer neurons - ';
H = input(prompt);

[w, v, trainerror] = mlptrain([x1;x2;x3],[y1;y2;y3], H, eta, nEpochs);
figure; plot(1:nEpochs, trainerror, 'b', 'LineWidth', 2); 
xlabel('Number of Epochs');
ylabel('Training Error');
title('Training Error vs Number of Epochs');

%%
ydash = mlptest(testX, w, v);

[val idx] = max(ydash, [], 2);

label = reshape(idx, size(a1));

% ploting the approximate decision boundary
% -------------------------------------------
figure;
imagesc([a1min a1max], [a2min a2max], label), hold on,
set(gca, 'ydir', 'normal'),

% colormap for the classes:
% class 1 = light red, 2 = light green, 3 = light blue
cmap = [1 0.8 0.8; 0.9 1 0.9; 0.9 0.9 1];
colormap(cmap);

% plot the training data
plot(x1(:,1),x1(:,2),'r.', 'LineWidth', 2),
plot(x2(:,1),x2(:,2),'g+', 'LineWidth', 2),
plot(x3(:,1),x3(:,2),'bo', 'LineWidth', 2),

legend('Class 1', 'Class 2', 'Class 3', 'Location', 'NorthOutside', ...
    'Orientation', 'horizontal');

% viewing the decision surface for the three classes
ydash1 = reshape(ydash(:,1), size(a1));
ydash2 = reshape(ydash(:,2), size(a1));
ydash3 = reshape(ydash(:,3), size(a1));

figure;
surf(a1, a2, ydash1, 'FaceColor', [1 0 0], 'FaceAlpha', 0.5), hold on,...
surf(a1, a2, ydash2, 'FaceColor', [0 1 0], 'FaceAlpha', 0.5), hold on,...
surf(a1, a2, ydash3, 'FaceColor', [0 0 1], 'FaceAlpha', 0.5);

function [w v trainerror] = mlptrain(X, Y, H, eta, nEpochs)
% X - training data of size NxD
% Y - training labels of size NxK
% H - the number of hidden layer units
% eta - the learning rate
% nEpochs - the number of training epochs
% define and initialize the neural network parameters

% number of training data points
N = size(X,1);
% number of inputs
D = size(X,2); % excluding the bias term
% number of outputs
K = size(Y,2);

% weights for the connections between input and hidden layer
% random values from the interval [-0.3 0.3]
% w is a Hx(D+1) matrix
w = -0.3+(0.6)*rand(H,(D+1));

% weights for the connections between hidden and output layer
% random values from the interval [-0.3 0.3]
% v is a Kx(H+1) matrix
v = -0.3+(0.6)*rand(K,(H+1));

% randomize the order in which the input data points are presented to the
% MLP
iporder = randperm(N);

% Adding bias term X0 = 1 to the input matrix
X1 = [ones(N,1) X];

% mlp training through stochastic gradient descent
for epoch = 1:nEpochs
    for n = 1:N
        % the current training point is X(iporder(n), :)
        % forward pass
        % --------------
        % input to hidden layer
        % calculate the output of the hidden layer units - z
        % ---------
        %'TO DO'%
        X_train = X1(iporder(n), :);
        % Calculating output of hidden layer
        H_layer = zeros(1,H);
        z = X_train * w';
        H_layer = sigmf(z,[1,0]);
        % ---------
        % hidden to output layer
        % calculate the output of the output layer units - ydash
        %'TO DO'%
        % ---------
        % Adding bias term H0 = 1 to hidden layer
        H_layer = [1 H_layer];
        z = v * H_layer';
        z = exp(z);
        S = sum(z);
        % Calculating output of output layer
        for i = 1:K
            O(1,i) = z(i,1)/S; 
        end
        % ---------
        
        % backward pass
        % ---------------
        % update the weights for the connections between hidden and
        % outlayer units
        % ---------
        %'TO DO'%
        for k = 1:K
            for h = 1:H+1
                v(k,h) = v(k,h) - eta*(O(1,k)-Y(iporder(n),k))*H_layer(1,h);
            end
        end
        % ---------
        % update the weights for the connections between the input and
        % hidden later units
        % ---------
        %'TO DO'%
        for h = 2:H+1
            for j = 1:D+1
                s = 0;
                for k = 1:K
                    s = s + ((O(1,k) - Y(iporder(n),k))*v(k,h));
                end
                w(h-1,j) = w(h-1,j) - eta*s*H_layer(1,h)*(1-H_layer(1,h))*X1(iporder(n),j);
            end
        end
        % ---------
    end
    ydash = mlptest(X, w, v);
    % compute the training error
    % ---------
    %'TO DO'% uncomment the next line after adding the necessary code
    error = 0;
    for i = 1:N
        for j = 1:K
            error = error-Y(i,j)*log(ydash(i,j));
        end
    end
    
    trainerror(epoch) = error;
    % ---------
    disp(sprintf('training error after epoch %d: %f\n',epoch,...
        trainerror(epoch)));
end
return;

function ydash = mlptest(X, w, v)
% forward pass of the network

% number of inputs
N = size(X,1);

% number of outputs
K = size(v,1);

% number of hidden layer nodes
H = size(w,1);

% Adding bias term X0 = 1 to the input matrix
X = [ones(N,1) X];
% Initializing Hidden Layer
Z = zeros(N,H);
% Initializing ydash
ydash = zeros(N,K);

% forward pass to estimate the outputs
% --------------------------------------
% input to hidden for all the data points
% calculate the output of the hidden layer units
% ---------
%'TO DO'%
Z = X * w';
Z = sigmf(Z,[1 0]);
% ---------% hidden to output for all the data points
% calculate the output of the output layer units
% ---------
%'TO DO'%
% Adding bias term to hidden layer Z
Z = [ones(N,1) Z];
for n = 1:N
    H_layer = Z(n, :);
    z = v * H_layer';
    z = exp(z);
    S = sum(z);
    % Calculating output of output layer
    for i = 1:K
        ydash(n,i) = z(i,1)/S; 
    end 
end
% ---------

return;