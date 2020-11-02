function [ut,xy,t] = diffusion2Dmodel()
%
%-----function help--------------------------------------------------------
% Simulating the 2-D Diffusion equation by the Finite Difference Method 
% Numerical scheme used is a first order upwind in time and a second 
% order central difference in space (Implicit and Explicit).
% Based on the code of Suraj Shanka, Copyright (c) 2012
% See Licence agreement for details of rights and permissions). 
% Downloaded from the Matlab Exchange Forum 3-Jan-2018.
%
% INPUT
%   Input values are hard coded
% COPYRIGHT
% CoastalSEA, (c) 2017, Suraj Shanka, (c) 2012
%--------------------------------------------------------------------------
    is3D = false;
    % unpack input data 
    nx = 20;
    ny = 30;    
    Lx = 100;
    Ly = 150;
    dc = 0.5;
    % model domain
    dx = Lx/(nx-1);
    dy = Ly/(ny-1);
    x = 0:dx:Lx;
    y = 0:dy:Ly;
    xy = {x',y'};            %assign xyz coordinates
    dt = 0.01;
    nt = 100;
    t = 0:dt:dt*nt;          %assign time variable
    u = zeros(nx,ny);
    ut = zeros(nt+1,nx,ny);
    % boundary conditions
    UE = 0;
    UW = 0;
    US = 0;
    UN = 0;
    BCoption = 1;             %selected boundary condition (1 or 2)  
    NumScheme = 1;            %selected numerical scheme (1 or 2)
    PkSize = 0.5;
    uPeak = 0.8;
%%
    %Initial Conditions
    for i=1:nx
        for j=1:ny
            offsetX = (1-PkSize)*Lx/2;
            offsetY = (1-PkSize)*Ly/2;
            if ((offsetY<=y(j))&&(y(j)<=Ly-offsetY) && ...
                                    (offsetX<=x(i))&&(x(i)<=Lx-offsetX))
                u(i,j)=uPeak;
            else
                u(i,j)=0;
            end
        end
    end
    ut(1,:,:) = u;
    
    if is3D
        %code to generate a simple 3D output
        xy = {x',y',1:3};      %assign xyz coordinates
        ut(1,:,:,2) = (u+fliplr(u))/2;
        ut(1,:,:,3) = fliplr(u);  
    end
%%
    %B.C vector and coefficient matrix for the implicit scheme
    [bc,D] = BCvector(BCoption);
%%
    %main computation loop
    i=2:nx-1;
    j=2:ny-1;
    for it=2:nt+1
        un=u;
        switch NumScheme
            case 1          %implicit scheme
                U=un;U(1,:)=[];U(end,:)=[];U(:,1)=[];U(:,end)=[];
                U=reshape(U+bc,[],1);
                U=D\U;
                U=reshape(U,nx-2,ny-2);
                u(2:nx-1,2:ny-1)=U;                
            case 2          %explicit scheme
                u(i,j)=un(i,j)+...
                    (dc*dt*(un(i+1,j)-2*un(i,j)+un(i-1,j))/(dx*dx))+...
                    (dc*dt*(un(i,j+1)-2*un(i,j)+un(i,j-1))/(dy*dy));
        end
        u = boundarycondition(u,BCoption);
        ut(it,:,:,1) = u;
        if is3D
            %code to generate a simple 3D output 
            ut(it,:,:,2) = (u+fliplr(u))/2;
            ut(it,:,:,3) = fliplr(u);
        end
    end

%%
    function [bc,D] = BCvector(BCoption)
        %set boundary condition vectors based on selected option
        bc=zeros(nx-2,ny-2);
        Ex=sparse(2:nx-2,1:nx-3,1,nx-2,nx-2);
        Ey=sparse(2:ny-2,1:ny-3,1,ny-2,ny-2);
        switch BCoption
            case 1    %Dirichlet B.Cs
                bc(1,:)=UW/dx^2; bc(nx-2,:)=UE/dx^2;  
                bc(:,1)=US/dy^2; bc(:,ny-2)=UN/dy^2;  
                %Calculating the coefficient matrix for the implicit scheme   
                Ax=Ex+Ex'-2*speye(nx-2);   
                Ay=Ey+Ey'-2*speye(ny-2);     
            case 2    %Neumann B.Cs
                bc(1,:)=-UW/dx; bc(nx-2,:)=UE/dx;
                bc(:,1)=-US/dy; bc(:,nx-2)=UN/dy;                          
                %Calculating the coefficient matrix for the implicit scheme
                Ax(1,1)=-1; Ax(nx-2,nx-2)=-1;
                Ay(1,1)=-1; Ay(ny-2,ny-2)=-1; 
        end
        bc(1,1)=UW/dx^2+US/dy^2; bc(nx-2,1)=UE/dx^2+US/dy^2;
        bc(1,ny-2)=UW/dx^2+UN/dy^2; bc(nx-2,ny-2)=UE/dx^2+UN/dy^2;
        bc=dc*dt*bc;
        A=kron(Ay/dy^2,speye(nx-2))+kron(speye(ny-2),Ax/dx^2);
        D=speye((nx-2)*(ny-2))-dc*dt*A;
    end
%%
    function u = boundarycondition(u,BCoption)
        switch BCoption
            case 1    %Dirichlet B.Cs
                u(1,:) = UW;
                u(nx,:)= UE;
                u(:,1) = US;
                u(:,ny)= UN;
            case 2    %Neumann B.Cs
                u(1,:) = u(2,:)-UW*dx;
                u(nx,:)= u(nx-1,:)+UE*dx;
                u(:,1) = u(:,2)-US*dy;
                u(:,ny)= u(:,ny-1)+UN*dy;
        end
    end
end


