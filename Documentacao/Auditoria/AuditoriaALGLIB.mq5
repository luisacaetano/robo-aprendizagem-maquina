// Auditoria descartavel: testa o comportamento real da ALGLIB do MT5. Nao envia ordens.
#property script_show_inputs false
#include <Math\Alglib\alglib.mqh>
int g_f=INVALID_HANDLE;
void Out(string s){ Print(s); if(g_f!=INVALID_HANDLE) FileWriteString(g_f,s+"\r\n"); }
double U(){ return ((MathRand()<<15)+MathRand()+0.5)/1073741824.0; }
void MakeNoise(CMatrixDouble &xy,int n,double pos){ xy.Resize(n,18); for(int i=0;i<n;i++){ for(int j=0;j<17;j++) xy.Set(i,j,U()); xy.Set(i,17,U()<pos?1.0:0.0);} }
void Rep(CMatrixDouble &src,int n,CMatrixDouble &dst,int &m){ // replica minoritaria ate empatar (1=minoritaria)
   int p=0; for(int i=0;i<n;i++) if(src.Get(i,17)>0.5) p++;
   int q=n-p; int k=(int)MathRound((double)q/p); m=q+p*k; dst.Resize(m,18); int c=0;
   for(int i=0;i<n;i++){ int t=(src.Get(i,17)>0.5)?k:1; for(int r=0;r<t;r++){ for(int j=0;j<18;j++) dst.Set(c,j,src.Get(i,j)); c++; } } }
void Down(CMatrixDouble &src,int n,CMatrixDouble &dst,int &m){ // controle: balanceia SEM duplicar
   int p=0; for(int i=0;i<n;i++) if(src.Get(i,17)>0.5) p++;
   m=2*p; dst.Resize(m,18); int c=0,z=0;
   for(int i=0;i<n;i++){ bool y=src.Get(i,17)>0.5; if(!y){ if(z>=p) continue; z++; } for(int j=0;j<18;j++) dst.Set(c,j,src.Get(i,j)); c++; } }
void Train(CMatrixDouble &xy,int n,int trees,double f,int vars,int seed,CDecisionForestShell &df,CDFReportShell &rep){
   CDecisionForestBuilder b; CAlglib::DFBuilderCreate(b); CAlglib::DFBuilderSetDataset(b,xy,n,17,2);
   CAlglib::DFBuilderSetSubsampleRatio(b,f); CAlglib::DFBuilderSetRndVars(b,vars); CAlglib::DFBuilderSetSeed(b,seed);
   CAlglib::DFBuilderBuildRandomForest(b,trees,df,rep); }
double ErrBal(CDecisionForestShell &df,int n){ int e=0; double x[17],y[]; for(int i=0;i<n;i++){ for(int j=0;j<17;j++) x[j]=U(); int t=i%2; CAlglib::DFProcess(df,x,y); if((y[1]>=0.5?1:0)!=t) e++; } return (double)e/n; }
void OnStart(){
   g_f=FileOpen("AuditoriaCV_alglib.txt",FILE_WRITE|FILE_TXT|FILE_ANSI);
   Out("=== build "+IntegerToString(TerminalInfoInteger(TERMINAL_BUILD)));
   MathSrand(12345);
   // T1 folha
   CMatrixDouble xy; MakeNoise(xy,2000,0.3); CDecisionForestShell df; CDFReportShell rep; double x[17],y[];
   for(int nt=1;nt<=100;nt+=99){ Train(xy,2000,nt,0.5,4,42,df,rep); int bin=0,inter=0,non=0;
      for(int i=0;i<5000;i++){ for(int j=0;j<17;j++) x[j]=U(); CAlglib::DFProcess(df,x,y); double p=y[1];
         if(p==0.0||p==1.0) bin++; else inter++; if(MathAbs(p*nt-MathRound(p*nt))>1e-9) non++; }
      Out(StringFormat("T1 folha arvores=%d: P exatamente 0/1=%d intermediario=%d P*arvores nao inteiro=%d",nt,bin,inter,non)); }
   // T1b: dados ruidosos com folha que poderia guardar proporcao: duplicatas com rotulos diferentes
   CMatrixDouble d; d.Resize(400,18); for(int i=0;i<400;i++){ double v=(i<200)?0.25:0.75; for(int j=0;j<17;j++) d.Set(i,j,v); d.Set(i,17,(i%10<3)?1.0:0.0);} // mesmo x, 30% rotulo 1
   Train(d,400,1,1.0,17,42,df,rep); for(int j=0;j<17;j++) x[j]=0.25; string s="T1b uma arvore, x identicos, 30% rotulo 1, P observados:"; int c0=0,c1=0,co=0;
   for(int sd=1;sd<=40;sd++){ Train(d,400,1,0.5,17,sd,df,rep); CAlglib::DFProcess(df,x,y); if(y[1]==0.0) c0++; else if(y[1]==1.0) c1++; else co++; }
   Out(StringFormat("%s P=0:%d P=1:%d outro:%d (proporcao daria 0,30)",s,c0,c1,co));
   // T2 OOB com ruido puro: erro honesto em dado balanceado = 50%
   double fs[3]={0.20,0.35,0.50};
   for(int k=0;k<3;k++){ double a=0,b=0,c=0,ta=0,tb=0,tc=0; int R=8;
      for(int r=0;r<R;r++){ CMatrixDouble src,dr,dd; int mr,md; MakeNoise(src,3000,0.26); Rep(src,3000,dr,mr); Down(src,3000,dd,md);
         Train(src,3000,100,fs[k],4,100+r,df,rep); a+=rep.GetOOBRelClsError(); ta+=ErrBal(df,2000);
         Train(dr,mr,100,fs[k],4,100+r,df,rep); b+=rep.GetOOBRelClsError(); tb+=ErrBal(df,2000);
         Train(dd,md,100,fs[k],4,100+r,df,rep); c+=rep.GetOOBRelClsError(); tc+=ErrBal(df,2000); }
      Out(StringFormat("T2 ruido f=%.2f | OOB: sem balancear=%.3f REPLICADO=%.3f subamostrado(controle)=%.3f | erro real em teste balanceado: %.3f %.3f %.3f",fs[k],a/R,b/R,c/R,ta/R,tb/R,tc/R)); }
   // T3 tempo
   int ns[4]={500,2000,5000,10000};
   for(int k=0;k<4;k++){ CMatrixDouble t; MakeNoise(t,ns[k],0.5); uint t0=GetTickCount(); Train(t,ns[k],100,0.35,4,42,df,rep); uint t1=GetTickCount(); Train(t,ns[k],100,0.5,8,42,df,rep); uint t2=GetTickCount();
      uint t3=GetTickCount(); for(int i=0;i<1000;i++){ for(int j=0;j<17;j++) x[j]=U(); CAlglib::DFProcess(df,x,y);} uint t4=GetTickCount();
      Out(StringFormat("T3 tempo n=%d: treino f=.35/4vars=%u ms; f=.50/8vars=%u ms; 1000 previsoes=%u ms",ns[k],t1-t0,t2-t1,t4-t3)); }
   // T4 semente e T5 serializacao
   CMatrixDouble z; MakeNoise(z,2000,0.3); CDecisionForestShell a1,a2,a3,a4; CDFReportShell r1; Train(z,2000,100,0.35,4,42,a1,r1); Train(z,2000,100,0.35,4,42,a2,r1); Train(z,2000,100,0.35,4,43,a3,r1);
   string ser; CAlglib::DFSerialize(a1,ser); CAlglib::DFUnserialize(ser,a4); double dm12=0,dm13=0,dm14=0,y1[],y2[],y3[],y4[];
   for(int i=0;i<2000;i++){ for(int j=0;j<17;j++) x[j]=U(); CAlglib::DFProcess(a1,x,y1); CAlglib::DFProcess(a2,x,y2); CAlglib::DFProcess(a3,x,y3); CAlglib::DFProcess(a4,x,y4); dm12=MathMax(dm12,MathAbs(y1[1]-y2[1])); dm13=MathMax(dm13,MathAbs(y1[1]-y3[1])); dm14=MathMax(dm14,MathAbs(y1[1]-y4[1])); }
   Out(StringFormat("T4 semente: mesma semente dif max=%.10f; semente diferente dif max=%.4f",dm12,dm13));
   Out(StringFormat("T5 serializacao: tamanho=%d dif max apos recarregar=%.10f",StringLen(ser),dm14));
   // T6 trecho do codigo da proposta (compila e roda)
   { CDecisionForestBuilder construtor; CDecisionForestShell floresta; CDFReportShell relatorio; CMatrixDouble mx; MakeNoise(mx,500,0.3); int nExemplos=500; double fracao=0.35; int nVariaveis=4;
     CAlglib::DFBuilderCreate(construtor); CAlglib::DFBuilderSetDataset(construtor,mx,nExemplos,17,2); CAlglib::DFBuilderSetSubsampleRatio(construtor,fracao); CAlglib::DFBuilderSetRndVars(construtor,nVariaveis); CAlglib::DFBuilderSetSeed(construtor,42); CAlglib::DFBuilderSetImportanceOOBGini(construtor); CAlglib::DFBuilderBuildRandomForest(construtor,100,floresta,relatorio);
     double xx[17],yy[]; for(int j=0;j<17;j++) xx[j]=0.5; CAlglib::DFProcess(floresta,xx,yy); string texto; CAlglib::DFSerialize(floresta,texto); Out(StringFormat("T6 codigo da proposta: ok, y[1]=%.3f, soma y=%.3f",yy[1],yy[0]+yy[1])); }
   Out("=== FIM");
   if(g_f!=INVALID_HANDLE) FileClose(g_f);
}
