CXX      = g++
CXXFLAGS = -O3 -g0
LDFLAGS  = $(CXXFLAGS)
LIBS     = -lcrypto -lresolv

dnsseed: dns.o bitcoin.o netbase.o protocol.o db.o main.o util.o
	g++ -pthread $(LDFLAGS) -o dnsseed dns.o bitcoin.o netbase.o protocol.o db.o main.o util.o -lcrypto -lresolv

%.o: %.cpp %.h
	$(CXX) -std=c++11 -pthread $(CXXFLAGS) \
        -Wall -Wno-unused -Wno-sign-compare -Wno-reorder -Wno-comment \
        -c -o $@ $<
