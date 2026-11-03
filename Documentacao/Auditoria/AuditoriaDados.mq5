// Auditoria descartavel: mede a regra da proposta no historico local do WIN$. Nao envia ordens.
int g_f=INVALID_HANDLE; void Out(string s){ Print(s); if(g_f!=INVALID_HANDLE) FileWriteString(g_f,s+"\r\n"); }
struct C { datetime t; int dia; int ano; int dir; double atr; int y; int saida; double pts; datetime fim; };
double Pct(double &a[],double q){ int n=ArraySize(a); if(n==0) return 0; double b[]; ArrayCopy(b,a); ArraySort(b); return b[(int)MathMin(n-1,q*n)]; }
int DayKey(datetime t){ MqlDateTime m; TimeToStruct(t,m); return m.year*10000+m.mon*100+m.day; }
int Min(datetime t){ MqlDateTime m; TimeToStruct(t,m); return m.hour*60+m.min; }
int Ano(datetime t){ MqlDateTime m; TimeToStruct(t,m); return m.year; }
void OnStart(){
   g_f=FileOpen("AuditoriaCV_dados.txt",FILE_WRITE|FILE_TXT|FILE_ANSI);
   string sym="WIN$"; SymbolSelect(sym,true); datetime from=D'2022.06.01', to=TimeCurrent()+86400;
   Out("TimeCurrent "+TimeToString(TimeCurrent())+" conectado="+IntegerToString(TerminalInfoInteger(TERMINAL_CONNECTED))+" maxbars="+IntegerToString(TerminalInfoInteger(TERMINAL_MAXBARS)));
   MqlRates m15[],m1[]; ArraySetAsSeries(m15,false); ArraySetAsSeries(m1,false);
   int n15=-1,n1=-1; for(int k=0;k<60;k++){ n15=CopyRates(sym,PERIOD_M15,from,to,m15); n1=CopyRates(sym,PERIOD_M1,from,to,m1); if(n15>0&&n1>0&&SeriesInfoInteger(sym,PERIOD_M1,SERIES_SYNCHRONIZED)) break; Sleep(1000);} 
   Out(StringFormat("barras M15=%d (%s a %s) M1=%d (%s a %s)",n15,n15>0?TimeToString(m15[0].time):"-",n15>0?TimeToString(m15[n15-1].time):"-",n1,n1>0?TimeToString(m1[0].time):"-",n1>0?TimeToString(m1[n1-1].time):"-"));
   if(n15<=0||n1<=0){ FileClose(g_f); return; }
   int ha=iADX(sym,PERIOD_M15,12), hb=iATR(sym,PERIOD_M15,14); for(int k=0;k<120&&(BarsCalculated(ha)<=0||BarsCalculated(hb)<=0);k++) Sleep(1000);
   double adx[],dip[],dim[],atr[]; ArraySetAsSeries(adx,false);ArraySetAsSeries(dip,false);ArraySetAsSeries(dim,false);ArraySetAsSeries(atr,false);
   int a0=CopyBuffer(ha,0,from,to,adx),a1=CopyBuffer(ha,1,from,to,dip),a2=CopyBuffer(ha,2,from,to,dim),a3=CopyBuffer(hb,0,from,to,atr);
   Out(StringFormat("buffers %d %d %d %d, calculados %d %d",a0,a1,a2,a3,BarsCalculated(ha),BarsCalculated(hb)));
   if(a0!=n15||a3!=n15){ Out("DESALINHADO"); FileClose(g_f); return; }
   // barras/pregoes por ano
   for(int y=2022;y<=2026;y++){ int d15=0,last=0,c15=0; for(int i=0;i<n15;i++) if(Ano(m15[i].time)==y){ c15++; int dk=DayKey(m15[i].time); if(dk!=last){d15++;last=dk;} } int c1=0,d1=0; last=0; for(int i=0;i<n1;i++) if(Ano(m1[i].time)==y){ c1++; int dk=DayKey(m1[i].time); if(dk!=last){d1++;last=dk;} } Out(StringFormat("ano %d: M15 barras=%d pregoes=%d | M1 barras=%d pregoes=%d",y,c15,d15,c1,d1)); }
   datetime ini=D'2023.01.01';
   C cs[]; ArrayResize(cs,0,100000); int p1=0; int dias[]; ArrayResize(dias,0,2000); int lastd=0; int nd=-1; int dayidx[]; ArrayResize(dayidx,n15);
   for(int i=0;i<n15;i++){ int dk=DayKey(m15[i].time); if(m15[i].time>=ini&&dk!=lastd){ nd++; lastd=dk; ArrayResize(dias,nd+1,2000); dias[nd]=dk; } dayidx[i]=nd; }
   int total=nd+1; Out("pregoes desde 2023="+IntegerToString(total));
   for(int i=30;i<n15-1;i++){ if(m15[i].time<ini) continue; if(adx[i]==EMPTY_VALUE||atr[i]<=0) continue; if(dayidx[i]!=dayidx[i+1]) continue;
      if(!(adx[i]>=20.0&&adx[i]>adx[i-1])) continue; int dir=0; if(dip[i]>dim[i]) dir=1; else if(dim[i]>dip[i]) dir=-1; if(dir==0) continue;
      datetime te=m15[i+1].time; int me=Min(te); if(me<9*60+15||me>17*60) continue;
      double e=m15[i+1].open, A=atr[i], stop=e-dir*1.5*A, tp=e+dir*3.0*A, trig=e+dir*1.5*A; bool be=false; int dk=DayKey(te);
      while(p1<n1&&m1[p1].time<te) p1++; int j=p1; int y=0,sa=3; double res=0; datetime fim=te; bool done=false;
      for(;j<n1&&DayKey(m1[j].time)==dk;j++){ if(Min(m1[j].time)>=17*60+30){ res=dir*(m1[j].open-e); fim=m1[j].time; sa=3; done=true; break; }
         bool hs=(dir>0)?(m1[j].low<=stop):(m1[j].high>=stop); bool ht=(dir>0)?(m1[j].high>=tp):(m1[j].low<=tp);
         if(hs){ res=dir*(stop-e); sa=be?2:0; fim=m1[j].time; done=true; break; } if(ht){ res=3.0*A; y=1; sa=1; fim=m1[j].time; done=true; break; }
         if(!be&&((dir>0)?(m1[j].high>=trig):(m1[j].low<=trig))){ be=true; stop=e; } }
      if(!done){ if(j>p1){ res=dir*(m1[j-1].close-e); fim=m1[j-1].time; } sa=3; }
      int n=ArraySize(cs); ArrayResize(cs,n+1,100000); cs[n].t=te; cs[n].dia=dayidx[i+1]; cs[n].ano=Ano(te); cs[n].dir=dir; cs[n].atr=A; cs[n].y=y; cs[n].saida=sa; cs[n].pts=res; cs[n].fim=fim; }
   int N=ArraySize(cs); Out("candidatos totais="+IntegerToString(N)+" por pregao="+DoubleToString((double)N/total,2));
   // janelas de candidatos
   int perDay[]; ArrayResize(perDay,total); ArrayInitialize(perDay,0); for(int i=0;i<N;i++) perDay[cs[i].dia]++;
   int W[3]={30,90,120}; for(int w=0;w<3;w++){ double v[]; ArrayResize(v,0,2000); for(int s=0;s+W[w]<=total;s++){ int c=0; for(int d=s;d<s+W[w];d++) c+=perDay[d]; int m=ArraySize(v); ArrayResize(v,m+1,2000); v[m]=c; } Out(StringFormat("candidatos por janela de %d pregoes: min=%.0f p10=%.0f mediana=%.0f max=%.0f",W[w],Pct(v,0),Pct(v,.1),Pct(v,.5),Pct(v,.9999))); }
   // rotulo
   for(int y=2023;y<=2027;y++){ int c=0,c1=0,s0=0,s2=0,s3=0,s3p=0; for(int i=0;i<N;i++) if(y==2027||cs[i].ano==y){ c++; if(cs[i].y==1)c1++; if(cs[i].saida==0)s0++; if(cs[i].saida==2)s2++; if(cs[i].saida==3){s3++; if(cs[i].pts>0)s3p++;} }
      if(c>0) Out(StringFormat("rotulo %s: n=%d y=1 %.1f%% | stop %.1f%% zero %.1f%% 17:30 %.1f%% (17:30 com lucro %.1f%%)",y==2027?"TOTAL":IntegerToString(y),c,100.0*c1/c,100.0*s0/c,100.0*s2/c,100.0*s3/c,100.0*s3p/c)); }
   // ATR e contratos
   for(int y=2023;y<=2027;y++){ double a[]; ArrayResize(a,0,50000); int c25[6],c50[6]; ArrayInitialize(c25,0);ArrayInitialize(c50,0); int ex25=0,ex50=0,cnt=0; for(int i=0;i<N;i++) if(y==2027||cs[i].ano==y){ int m=ArraySize(a); ArrayResize(a,m+1,50000); a[m]=cs[i].atr; double risk=1.5*cs[i].atr*0.20; int k25=(int)MathFloor(50.0/risk),k50=(int)MathFloor(100.0/risk); if(k25<1)ex25++; if(k50<1)ex50++; k25=MathMax(1,MathMin(5,k25)); k50=MathMax(1,MathMin(5,k50)); c25[k25]++; c50[k50]++; cnt++; }
      if(cnt>0) Out(StringFormat("ATR %s: p10=%.0f p50=%.0f p90=%.0f | R=0,25%%: 1c=%.0f%% 2c=%.0f%% 3+=%.0f%% acima do risco=%.0f%% | R=0,50%%: 1c=%.0f%% 2c=%.0f%% 3+=%.0f%% acima=%.0f%%",y==2027?"TOTAL":IntegerToString(y),Pct(a,.1),Pct(a,.5),Pct(a,.9),100.0*c25[1]/cnt,100.0*c25[2]/cnt,100.0*(cnt-c25[1]-c25[2])/cnt,100.0*ex25/cnt,100.0*c50[1]/cnt,100.0*c50[2]/cnt,100.0*(cnt-c50[1]-c50[2])/cnt,100.0*ex50/cnt)); }
   // operacao sem filtro: 1 posicao, 4 por dia, para apos 3 stops seguidos, 1 contrato
   double tp_[],td_[]; int ta_[]; int tdia[]; ArrayResize(tp_,0,20000); ArrayResize(tdia,0,20000); ArrayResize(ta_,0,20000); datetime busy=0; int cd=-1,ops=0,seq=0;
   for(int i=0;i<N;i++){ if(cs[i].dia!=cd){cd=cs[i].dia;ops=0;seq=0;} if(cs[i].t<busy||ops>=4||seq>=3) continue; int m=ArraySize(tp_); ArrayResize(tp_,m+1,20000); ArrayResize(tdia,m+1,20000); ArrayResize(ta_,m+1,20000); tp_[m]=cs[i].pts*0.20; tdia[m]=cs[i].dia; ta_[m]=cs[i].ano; busy=cs[i].fim; ops++; if(cs[i].saida==0) seq++; else seq=0; }
   int M=ArraySize(tp_); double cst[2]={0.0,3.0};
   for(int y=2023;y<=2027;y++) for(int q=0;q<2;q++){ double g=0,l=0; int c=0; for(int i=0;i<M;i++) if(y==2027||ta_[i]==y){ double v=tp_[i]-cst[q]; if(v>0)g+=v; else l-=v; c++; } if(c>0) Out(StringFormat("sem filtro %s custo R$%.0f: n=%d FL=%.3f liquido=%.0f",y==2027?"TOTAL":IntegerToString(y),cst[q],c,l>0?g/l:0,g-l)); }
   // ciclos: validacao 30 pregoes depois de 90, avanca 20
   int cic=0,menor20=0,inval=0; double nv[]; ArrayResize(nv,0,100); for(int s=90;s+30<=total;s+=20){ int c=0; double g=0,l=0; for(int i=0;i<M;i++) if(tdia[i]>=s&&tdia[i]<s+30){ double v=tp_[i]-3.0; if(v>0)g+=v; else l-=v; c++; } cic++; int m=ArraySize(nv); ArrayResize(nv,m+1,100); nv[m]=c; if(c<20) menor20++; if(c<20||l<=0||g/l<1.05) inval++; }
   Out(StringFormat("validacao sem filtro: ciclos=%d operacoes em 30 pregoes min=%.0f mediana=%.0f max=%.0f | ciclos com N<20=%d | ciclos reprovados (N<20 ou FL<1,05 com custos)=%d",cic,Pct(nv,0),Pct(nv,.5),Pct(nv,.9999),menor20,inval));
   Out("=== FIM"); FileClose(g_f);
}
